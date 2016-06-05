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
// release pathing that ONLY targets the official beardedspice master branch
static NSString *const kBSVersionIndexURL = @"https://raw.githubusercontent.com/beardedspice/beardedspice/master/BeardedSpice/MediaStrategies/%@.%@";

// This is the name of the version index plist to be downloaded.
static NSString *const kBSIndexFileName = @"versions";

@interface BSStrategyVersionManager ()

@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSURL *versionURL;
@property (nonatomic, strong) BSStrategyCache *strategyCache;

- (NSURL * _Nonnull)repositoryURLForFile:(NSString *)file;
- (BOOL)updateStrategiesFromSourceURL:(NSURL * _Nonnull)path;

@end

@implementation BSStrategyVersionManager

- (instancetype)initWithStrategyCache:(BSStrategyCache *)cache
{
    self = [super init];
    if (self)
    {
        _versionURL = [self repositoryURLForFile:kBSIndexFileName ofType:@"plist"];
        _strategyCache = cache;
    }
    return self;
}

#pragma mark - Version Accessors

- (long)versionForMediaStrategy:(NSString *)mediaStrategy
{
    if (!mediaStrategy || !mediaStrategy.length)
        return kBSVersionErrorInvalidInput;

    BSMediaStrategy *stratery = [_strategyCache strategyForName:mediaStrategy];
    if (stratery)
        return stratery.strategyVersion;

    return kBSVersionErrorNotFound;
}

- (NSURL * _Nonnull)repositoryURLForFile:(NSString *)file
{
    return [self repositoryURLForFile:file ofType:@"js"];
}

- (NSURL * _Nonnull)repositoryURLForFile:(NSString *)file ofType:(NSString *_Nonnull)type
{
    // target source for strategy version
    NSString *path = [[NSString alloc] initWithFormat:kBSVersionIndexURL, file, type];

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

@end
