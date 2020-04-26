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


NSString *BSVMStrategyChangedNotification = @"BSVMStrategyChangedNotification";

@interface BSStrategyVersionManager ()

@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, strong) NSURL *versionURL;
@property (nonatomic, strong) BSStrategyCache *strategyCache;

- (NSURL * _Nonnull)repositoryURLForFile:(NSString *)file;

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

- (BSMediaStrategy *)mediaStrategy:(NSString *)mediaStrategy
{
    if (!mediaStrategy || !mediaStrategy.length)
        return nil;

    return [_strategyCache strategyForFileName:[mediaStrategy stringByAppendingString:@".js"]];
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
    dispatch_group_t group = dispatch_group_create();
    if (group) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
        for (NSString *key in newVersions)
        {
            
            long version = 0;
            // we think that even custom strategy must be reloaded if new version arrived from backend server
            BSMediaStrategy *strategy = [self mediaStrategy:key];
            version = strategy.strategyVersion;
            
            long newVersion = [newVersions[key] longValue];
            if (version >= newVersion) // greater than
                continue;
            
            foundNewVersions++;
            __weak typeof(self) wself = self; // new pointer for self to avoid autoretain cycles
            dispatch_group_async(group, queue, ^{
                
                __strong typeof(wself) sself = wself;
                BOOL ret = [sself performUpdateOfMediaStrategy:key];
                if (!ret) // if the file failed to save/wasn't valid
                    foundNewVersions--;
            });
            
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        if (foundNewVersions) {
            [self notifyThatChanged];
        }
    }
    else{
        NSLog(@"Error of creating of the queue group!");
    }

    return foundNewVersions;
}

- (BOOL)performUpdateOfMediaStrategy:(NSString *)mediaStrategy
{
    NSError *error = nil;
    NSURL *pathURL = [self repositoryURLForFile:mediaStrategy];
    // download from remote repository
    BSMediaStrategy *newVersions = [BSMediaStrategy mediaStrategyWithURL:pathURL error:nil];
    if (!newVersions)
    {
        NSLog(@"Error downloading strategy \"%@\"", mediaStrategy);
        return NO;
    }

    error = nil; // reset the local error
    NSURL *pathToFile = [NSURL URLForFileName:mediaStrategy];
    BOOL success = [newVersions.strategyJsBody writeToURL:pathToFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        NSLog(@"Error saving strategy %@: %@", mediaStrategy, [error localizedDescription]);
        return NO;
    }

    if (!success)
        return NO;

    NSError *err = [self.strategyCache updateStrategyWithURL:pathToFile];
    if (!err) {
        return  YES;
    }
    
    if (err.code == BSSC_ERROR_STRATEGY_NOTFOUND) {
        
        BSMediaStrategy *newStrategy = [self.strategyCache addStrategyWithURL:pathToFile];
        if (newStrategy) {
            
            [[MediaStrategyRegistry singleton] addAvailableMediaStrategy:newStrategy];
            return YES;
        }
    };
    
    return NO;
}

#pragma mark - Helper Methods

- (void)notifyThatChanged{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BSVMStrategyChangedNotification
         object:self];
    });
}
@end
