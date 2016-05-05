//
//  BSStrategyVersionManager.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyVersionManager.h"
#import "MediaStrategyRegistry.h"
#import "BSMediaStrategy.h"

// This is the path format which requires a user/branch/filename for the target plist file.
#ifndef DEBUG
// release pathing that ONLY targets the official beardedspice master branch
static NSString *const kBSVersionIndexURL = @"https://raw.githubusercontent.com/beardedspice/beardedspice/master/BeardedSpice/MediaStrategies/%@.js";
#else
// development pathing that allows dynamic branch assignment
static NSString *const kBSVersionIndexURL = @"https://raw.githubusercontent.com/%@/beardedspice/%@/BeardedSpice/MediaStrategies/%@.js";
#endif

// This is to determine which repo fork we're working off
static NSString *const kBSBundleIdentifierForRepo = @"BSRepositoryOwner";
// This is to determine which branch of the repository we're working off
static NSString *const kBSBundleIdentifierForBranch = @"BSRepositoryBranch";
// This is the name of the version index plist to be downloaded.
static NSString *const kBSIndexFileName = @"versions";
// The key in the version index for the version of the index itself
static NSString *const kBSIndexVersion = @"version";


@interface BSStrategyVersionManager ()

@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSURL *versionURL;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *currentVersions;

- (NSURL * _Nonnull)repositoryURLForFile:(NSString *)file;

@end

@implementation BSStrategyVersionManager

+ (BSStrategyVersionManager *)sharedVersionManager
{
    static dispatch_once_t setupManager;
    static BSStrategyVersionManager *versionManager;

    dispatch_once(&setupManager, ^{
        versionManager = [BSStrategyVersionManager new];
    });

    return versionManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _versionURL = [self repositoryURLForFile:kBSIndexFileName];

        [self setupVersionFile];
        [self setupStrategyFiles];
    }
    return self;
}

#pragma mark - Setup and Maintenance functions

- (void)setupVersionFile
{
    // load from application support mutable file. Otherwise copy the bundle'd file there and load it.
    NSURL *path = [NSURL versionsFileFromURL];
    NSURL *versionPath = [[NSBundle mainBundle] URLForResource:@"versions" withExtension:@"plist"];
    BOOL success = [path fileExists] ? YES : [versionPath copyFileTo:@"versions"];
    if (success)
        _currentVersions = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
}

- (void)setupStrategyFiles
{
    // load from application support mutable file. Otherwise copy the bundle'd file(s) there and load it.
    for (NSString *fileName in [MediaStrategyRegistry getDefaultMediaStrategyNames])
    {
        NSURL *path = [NSURL fileFromURL:fileName];
        NSURL *versionPath = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"plist"];
        if (![path fileExists])
            [versionPath copyFileTo:fileName];
    }
}

- (BOOL)saveVersions:(NSMutableDictionary<NSString *, NSNumber *> *)updateVersions
{
    NSParameterAssert(updateVersions != nil);
    NSParameterAssert(updateVersions.count > 0);

    self.currentVersions = updateVersions;

    NSURL *path = [NSURL versionsFileFromURL];
    return [_currentVersions writeToURL:path atomically:YES];
}

#pragma mark - Version Accessors

- (long)indexVersion
{
    NSNumber *version = _currentVersions[kBSIndexVersion];
    if (!version)
        return kBSVersionErrorNotFound;

    return [version longValue];
}

- (long)versionForMediaStrategy:(NSString *)mediaStrategy
{
    if (!mediaStrategy || !mediaStrategy.length)
        return kBSVersionErrorInvalidInput;

    NSNumber *version = _currentVersions[mediaStrategy];
    if (version)
        return [version longValue];

    return kBSVersionErrorNotFound;
}

- (NSURL * _Nonnull)repositoryURLForFile:(NSString *)file
{
    // target source for strategy version
#ifndef DEBUG
    NSString *path = [[NSString alloc] initWithFormat:kBSVersionIndexURL, file];
#else
    NSString *repoIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:kBSBundleIdentifierForRepo];
    NSString *branchIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:kBSBundleIdentifierForBranch];
    NSString *path = [[NSString alloc] initWithFormat:kBSVersionIndexURL, repoIdentifier, branchIdentifier, file];
#endif

    return [NSURL URLWithString:path];
}

#pragma mark - Network Operations

- (void)performUpdateCheck
{
    __weak typeof(self) wself = self; // new pointer for self to avoid autoretain cycles
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        __strong typeof(wself) sself = wself;
        [sself performSyncUpdateCheck];
    });
}

- (NSUInteger)performSyncUpdateCheck
{
    self.lastUpdated = [NSDate date];
    NSMutableDictionary<NSString *, NSNumber *> *newVersions = [[NSMutableDictionary alloc] initWithContentsOfURL:_versionURL];

    NSUInteger foundNewVersions = 0;
    for (NSString *key in newVersions)
    {
        long version = [self versionForMediaStrategy:key];
        long newVersion = [newVersions[key] longValue];
        if (version >= newVersion) // greater than? wat.
            continue;

        foundNewVersions++;
        __weak typeof(self) wself = self; // new pointer for self to avoid autoretain cycles
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
            __strong typeof(wself) sself = wself;
            [sself performUpdateOfMediaStrategy:key];
        });
    }

    if (foundNewVersions > 0)
        [self saveVersions:newVersions];

    return foundNewVersions;
}

- (BOOL)performUpdateOfMediaStrategy:(NSString *)mediaStrategy
{
    NSURL *pathURL = [self repositoryURLForFile:mediaStrategy];
    NSDictionary *newVersions = [[NSDictionary alloc] initWithContentsOfURL:pathURL];
    if (!newVersions || !newVersions.count)
        return NO;

    NSURL *pathToFile = [NSURL fileFromURL:mediaStrategy];
    return [newVersions writeToURL:pathToFile atomically:YES];
}

@end
