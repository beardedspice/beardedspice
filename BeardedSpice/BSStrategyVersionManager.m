//
//  BSStrategyVersionManager.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyVersionManager.h"

#import "MediaStrategyRegistry.h"
#import "BSStrategyCache.h"
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
@property (nonatomic, strong) BSStrategyCache *strategyCache;

- (NSURL * _Nonnull)repositoryURLForFile:(NSString *)file;
- (BOOL)updateStrategiesFromSourceURL:(NSURL * _Nonnull)path;

@end

@implementation BSStrategyVersionManager

-(instancetype)initWithStrategyCache:(BSStrategyCache *)cache
{
    self = [super init];
    if (self)
    {
        _versionURL = [self repositoryURLForFile:kBSIndexFileName];
        _strategyCache = cache;

        [self setupVersionFile];
        [self setupStrategyFiles];
    }
    return self;
}

#pragma mark - Setup and Maintenance functions

- (void)setupVersionFile
{
    // load from application support mutable file. Otherwise copy the bundle'd file there and load it.
    NSURL *path = [NSURL URLForVersionsFile];
    if ([path fileExists])
        _currentVersions = [[NSMutableDictionary alloc] initWithContentsOfURL:path];
}

- (void)setupStrategyFiles
{
    NSArray<NSString *> *fileNames = [self.strategyCache allKeys];
    // load from application support mutable file. Otherwise copy the bundle'd file(s) there and load it.
    for (NSString *fileName in fileNames)
    {
        NSURL *path = [NSURL URLForFileName:fileName];
        NSURL *versionPath = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"js"];
        if (![path fileExists])
            [versionPath copyStrategyToAppSupport:fileName];
    }
}

- (BOOL)saveVersions:(NSMutableDictionary<NSString *, NSNumber *> *)updateVersions
{
    NSParameterAssert(updateVersions != nil);
    NSParameterAssert(updateVersions.count > 0);

    self.currentVersions = updateVersions;

    NSURL *path = [NSURL URLForVersionsFile];
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

    __block NSUInteger foundNewVersions = 0;
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
            BOOL ret = [sself performUpdateOfMediaStrategy:key];
            if (!ret) // if the file failed to save/wasn't valid
                foundNewVersions--;
        });
    }

    if (foundNewVersions > 0)
        [self saveVersions:newVersions];

    return foundNewVersions;
}

- (BOOL)performUpdateOfMediaStrategy:(NSString *)mediaStrategy
{
    NSError *error = nil;
    NSURL *pathURL = [self repositoryURLForFile:mediaStrategy];
    // download from remote repository
    NSString *newVersions = [[NSString alloc] initWithContentsOfURL:pathURL encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"Error downloading strategy %@: %@", mediaStrategy, [error localizedDescription]);
        return NO;
    }

    if (!newVersions || !newVersions.length)
        return NO;

    error = nil; // reset the local error
    NSURL *pathToFile = [NSURL URLForFileName:mediaStrategy];
    BOOL success = [newVersions writeToURL:pathToFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"Error saving strategy %@: %@", mediaStrategy, [error localizedDescription]);
        return NO;
    }

    if (!success)
        return NO;

    [self.strategyCache updateCacheWithURL:pathToFile];
    BSMediaStrategy *strategy = [self.strategyCache strategyForName:mediaStrategy];
    return strategy.isLoaded;
}

#pragma mark - Cache Management

- (BOOL)loadStrategies
{
    if (!_strategyCache)
        return NO;

    NSURL *savedURL = [NSURL URLForSavedStrategies];
    BOOL ret = [savedURL createDirectoriesToURL];
    if (!ret)
        return NO;

    //if (![savedURL directoryExists])
    {
        NSURL *indexFile = [NSURL URLForVersionsFile];
        NSDictionary *index = [NSDictionary dictionaryWithContentsOfURL:indexFile];
        for (NSString *fileName in index)
        {
            NSURL *filePath = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"js"];
            [filePath copyStrategyToAppSupport:fileName];
        }
    }

    ret = [self updateStrategiesFromSourceURL:savedURL];
    if (!ret)
        return NO;

    NSURL *customURL = [NSURL URLForCustomStrategies];
    ret = [self updateStrategiesFromSourceURL:customURL];
    if (!ret)
        NSLog(@"Warning updating custom strategies. Reverting to official.");

    return YES;
}

// FIXME assumes strategies copied to AppSupport at first run
- (BOOL)updateStrategiesFromSourceURL:(NSURL * _Nonnull)path
{
    NSError *error = nil;
    NSString *absPath = path.path;
    BOOL success = [path createDirectoriesToURL];
    if (!success)
        return NO;

    NSArray<NSString *> *elements = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absPath error:&error];
    if (error)
    {
        NSLog(@"Error updating strategies from URL (%@): %@", absPath, [error localizedDescription]);
        return NO;
    }

    for (NSString *fileName in elements)
    {
        NSURL *filePath = [[NSURL alloc] initWithString:fileName relativeToURL:path];
        [_strategyCache updateCacheWithURL:filePath];
    }
    return YES;
}

@end
