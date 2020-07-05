//
//  BSStrategyVersionManager.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyVersionManager.h"
#import "BSSharedResources.h"

#import "MediaStrategyRegistry.h"
#import "BSStrategyCache.h"
#import "BSMediaStrategy.h"

NSString *BSVMStrategyChangedNotification = @"BSVMStrategyChangedNotification";
NSString *const BSVMStrategyErrorDomain = @"BSVMStrategyErrorDomain";

@interface BSStrategyVersionManager ()

@property (nonatomic, strong) BSStrategyCache *strategyCache;
@end

@implementation BSStrategyVersionManager

- (instancetype)initWithStrategyCache:(BSStrategyCache *)cache
{
    self = [super init];
    if (self)
    {
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


#pragma mark - Network Operations

- (void)updateStrategiesWithCompletion:(void (^)(NSArray<NSString *> *updatedNames, NSError *error))completion {
    
    ASSIGN_WEAK(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ASSIGN_STRONG(self);
        NSError *err;
        NSDictionary<NSString *, NSDictionary *> *manifest = [USE_STRONG(self) manifestWithError:&err];
        if (manifest == nil) {
            if (completion) {
                completion(nil, err);
            }
            return;
        }
        NSMutableArray<NSString *> *updatedNames = [NSMutableArray new];
        dispatch_group_t group = dispatch_group_create();
        if (group) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
            for (NSString *key in manifest) {
                
                long version = 0;
                
                // we think that even custom strategy must be reloaded if new version arrived from backend server
                BSMediaStrategy *strategy = [USE_STRONG(self) mediaStrategy:key];
                version = strategy.strategyVersion;
                
                long newVersion = [manifest[key][@"version"] longValue];
                if (version >= newVersion) // greater than
                    continue;
                
                dispatch_group_async(group, queue, ^{
                    ASSIGN_STRONG(self);
                    if ([USE_STRONG(self) performUpdateOfMediaStrategy:key]) // if the file failed to save/wasn't valid
                        [updatedNames addObject:manifest[key][@"name"]];
                });
                
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            if (updatedNames.count) {
                [USE_STRONG(self) notifyThatChanged];
            }
        }
        else{
            DDLogError(@"Error of creating of the queue group!");
        }
        
        if (completion) {
            completion(updatedNames, nil);
        }
    });
}

- (BOOL)performUpdateOfMediaStrategy:(NSString *)mediaStrategy
{
    NSError *error = nil;
    NSURL *pathURL = [NSURL URLWithString:[NSString stringWithFormat:BS_STRATEGY_URL_FORMAT, mediaStrategy]];
    // download from remote repository
    BSMediaStrategy *newVersions = [BSMediaStrategy mediaStrategyWithURL:pathURL error:nil];
    if (!newVersions)
    {
        DDLogError(@"Error downloading strategy \"%@\"", mediaStrategy);
        return NO;
    }

    error = nil; // reset the local error
    NSURL *pathToFile = [NSURL URLForFileName:mediaStrategy];
    BOOL success = [newVersions.strategyJsBody writeToURL:pathToFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        DDLogError(@"Error saving strategy %@: %@", mediaStrategy, [error localizedDescription]);
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
 
- (NSDictionary <NSString *, NSDictionary *> *)manifestWithError:(NSError **)error {
    
    NSURL *url = [NSURL URLWithString:BS_STRATEGY_JSON_URL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data.length) {
        NSError *err = [NSError errorWithDomain:BSVMStrategyErrorDomain
                                           code:BSVMS_ERROR_MANIFEST_DOWNLOAD
                                       userInfo:@{
                                           NSLocalizedDescriptionKey: @"TODO: ERROR DESCR"
                                       }];
        DDLogError(@"Can't download manifest.json from: %@", BS_UNSUPPORTED_STRATEGY_JSON_URL);
        if (error) {
            *error = err;
        }
        return  nil;
    }
    NSError *err;
    NSDictionary<NSString *, NSDictionary *> *manifest = [NSJSONSerialization JSONObjectWithData:data
                                                                                         options:0
                                                                                           error:&err];
    if (manifest == nil) {
        err = [NSError errorWithDomain:BSVMStrategyErrorDomain
                                  code:BSVMS_ERROR_MANIFEST_PARSE
                              userInfo:@{
                                  NSUnderlyingErrorKey: err,
                                  NSLocalizedDescriptionKey: @"TODO: ERROR DESCR"
                              }];
        DDLogError(@"Can't parse manifest.json from: %@", BS_UNSUPPORTED_STRATEGY_JSON_URL);
        if (error) {
            *error = err;
        }
    }
    return manifest;
}


@end
