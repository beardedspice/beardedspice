//
//  BSCustomStrategyManager.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 25.06.16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSCustomStrategyManager.h"
#import "BSMediaStrategy.h"
#import "AppDelegate.h"
#import "NSURL+Utils.h"
#import "MediaStrategyRegistry.h"
#import "BSStrategyCache.h"

NSString *BSCStrategyChangedNotification = @"BSCStrategyChangedNotification";
NSString *const BSCStrategyErrorDomain = @"BSCStrategyErrorDomain";

#define STRATEGY_FOLDER_NAME                    @"Strategies"
#define STRATEGY_FOLDER_NAME_COUNTER_MAX        9999

@implementation BSCustomStrategyManager

static BSCustomStrategyManager *singletonCustomStrategyManager;

/////////////////////////////////////////////////////////////////////
#pragma mark - Initialize

+ (BSCustomStrategyManager *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonCustomStrategyManager = [BSCustomStrategyManager alloc];
        singletonCustomStrategyManager = [singletonCustomStrategyManager init];
    });
    
    return singletonCustomStrategyManager;
    
}

- (id)init{
    
    if (singletonCustomStrategyManager != self) {
        return nil;
    }
    self = [super init];
    
    return self;
}

/////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods

- (BOOL)importFromUrl:(NSURL *)url
           completion:(void (^)(BSMediaStrategy *strategy, NSError *error))completion {
    
    if (!url) {
        if (completion) {
            completion(nil, nil);
        }
        return NO;
    }
    
    NSError *error = nil;
    BSMediaStrategy *strategy = [BSMediaStrategy mediaStrategyWithURL:url error:&error];
    if (strategy) {
        
        error = nil; // reset the local error
        
        NSURL *pathToFile = [NSURL URLForCustomStrategies];
        pathToFile = [pathToFile URLByAppendingPathComponent:strategy.fileName];
        [strategy.strategyJsBody writeToURL:pathToFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error)
        {
            DDLogError(@"Error saving strategy %@: %@", strategy, [error localizedDescription]);
        }
        else{
            
            MediaStrategyRegistry *registry = [MediaStrategyRegistry singleton];
            error = [registry.strategyCache updateStrategyWithURL:pathToFile];
            
            if (error.code == BSSC_ERROR_STRATEGY_NOTFOUND) {
                
                BSMediaStrategy *newStrategy = [registry.strategyCache addStrategyWithURL:pathToFile];
                if (newStrategy) {
                    
                    [registry addAvailableMediaStrategy:newStrategy];
                    error = nil;
                }
            };
        }
    }
    
    if (completion) {
        completion(strategy, error);
    }
    return (error == nil);
}

- (void)exportStrategy:(BSMediaStrategy *)strategy
              toFolder:(NSURL *)folderURL
             overwrite:(BOOL(^)(NSURL *pathToFile))overwrite
            completion:(void (^)(NSURL *pathToFile, NSError *error))completion {

    if (!(strategy && folderURL)) {
        if (completion) {
            completion(nil, nil);
        }
        return;
    }

    NSError *error = nil;
    NSString *fileName = [[strategy.fileName stringByDeletingPathExtension]
        stringByAppendingString:@"." BS_STRATEGY_EXTENSION];
    NSURL *pathToFile = [folderURL URLByAppendingPathComponent:fileName];

    if ([pathToFile checkResourceIsReachableAndReturnError:nil]) {
        if (overwrite == nil || overwrite(pathToFile) == NO) {
            if (completion) {
                completion(nil, nil);
            }
            return;
        }
    }

    [strategy.strategyJsBody writeToURL:pathToFile
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:&error];
    
    if (error) {
        DDLogError(@"Error saving strategy %@: %@", strategy,
              [error localizedDescription]);
    }
    
    if (completion) {
        completion(pathToFile, error);
    }
}

- (BOOL)removeStrategy:(BSMediaStrategy *)strategy
            completion:(void (^)(BSMediaStrategy *replacedStrategy, NSError *error))completion{
    
    if (!strategy.custom) {
        if (completion) {
            completion(nil, nil);
        }
        return NO;
    }
    NSError *error = nil;
    BSMediaStrategy *newStrategy;
    [[NSFileManager defaultManager] removeItemAtURL:strategy.strategyURL error:&error];
    if (error)
    {
        DDLogError(@"Error removing strategy %@: %@", strategy, [error localizedDescription]);
    }
    else{
        
        BSStrategyCache *cache = [[MediaStrategyRegistry singleton] strategyCache];
        
        [[MediaStrategyRegistry singleton] removeAvailableMediaStrategy:strategy];
        [cache removeStrategyFromCache:strategy.fileName];

        NSURL *alternativeURL = [[NSURL URLForSavedStrategies] URLByAppendingPathComponent:strategy.fileName];
        newStrategy = [cache addStrategyWithURL:alternativeURL];
        if (!newStrategy) {
            alternativeURL = [[NSURL URLForBundleStrategies] URLByAppendingPathComponent:strategy.fileName];
            newStrategy = [cache addStrategyWithURL:alternativeURL];
        }
        
        if (newStrategy) {
            
            [[MediaStrategyRegistry singleton] addAvailableMediaStrategy:newStrategy];
        }
        
        // Good
//          [self notifyThatChanged];
    }
    if (completion) {
        completion(newStrategy, error);
    }
    return (error == nil);
}

- (void)updateCustomStrategiesFromUnsupportedRepoWithCompletion:(void (^)(NSArray<NSString *> *updatedNames, NSError *error))completion {
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
            
            BSStrategyCache *cache = MediaStrategyRegistry.singleton.strategyCache;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
            for (NSString *key in manifest)
            {
                
                long version = 0;
                // we think that even custom strategy must be reloaded if new version arrived from backend server
                
                BSMediaStrategy *strategy = [cache strategyForFileName:[key stringByAppendingPathExtension:@"js"]];
                version = strategy.strategyVersion;
                
                long newVersion = [manifest[key][@"version"] longValue];
                if (version >= newVersion) // greater than
                    continue;
                
                dispatch_group_async(group, queue, ^{
                    
                    ASSIGN_STRONG(self);
                    NSURL *newStrategyUrl = [NSURL URLWithString:[NSString stringWithFormat:BS_UNSUPPORTED_STRATEGY_URL_FORMAT, key]];
                    if (newStrategyUrl) {
                        if ([USE_STRONG(self) importFromUrl:newStrategyUrl completion:nil]) {
                            [updatedNames addObject:manifest[key][@"name"]];
                        }
                    }
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

- (void)downloadCustomStrategiesFromUnsupportedRepoTo:(NSURL *)targetUrl completion:(void (^)(NSURL *folderUrl, NSError *error))completion {
    ASSIGN_WEAK(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        ASSIGN_STRONG(self);
        NSURL *saveUrl = [USE_STRONG(self) createExportFolder:targetUrl];
        if (saveUrl == nil ) {
            NSError *error = [NSError errorWithDomain:BSCStrategyErrorDomain
                                                 code:BSCS_ERROR_CREATE_SAVING_FOLDER
                                             userInfo:@{}];
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        NSError *err;
        NSDictionary<NSString *, NSDictionary *> *manifest = [USE_STRONG(self) manifestWithError:&err];
        if (manifest == nil) {
            if (completion) {
                completion(nil, err);
            }
            return;
        }
        dispatch_group_t group = dispatch_group_create();
        if (group) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
            for (NSString *key in manifest)
            {
                
                dispatch_group_async(group, queue, ^{
                    
                    NSURL *newStrategyUrl = [NSURL URLWithString:[NSString stringWithFormat:BS_UNSUPPORTED_STRATEGY_URL_FORMAT, key]];
                    if (newStrategyUrl) {
                        NSError *error;
                        BSMediaStrategy *strategy = [BSMediaStrategy mediaStrategyWithURL:newStrategyUrl error:&error];
                        if (strategy) {
                            
                            error = nil; // reset the local error
                            
                            NSURL *pathToFile = [saveUrl URLByAppendingPathComponent:[strategy.strategyURL lastPathComponent]];
                            [strategy.strategyJsBody writeToURL:pathToFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
                            if (error) {
                                DDLogError(@"Error saving strategy %@: %@", strategy, [error localizedDescription]);
                            }
                        }
                    }
                });
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        }
        else{
            DDLogError(@"Error of creating of the queue group!");
        }
        
        if (completion) {
            completion(saveUrl, nil);
        }
    });
}

/////////////////////////////////////////////////////////////////////
#pragma mark - Helper Methods

- (void)notifyThatChanged{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BSCStrategyChangedNotification
         object:self];
    });
}

- (NSDictionary <NSString *, NSDictionary *> *)manifestWithError:(NSError **)error {
    
    NSURL *url = [NSURL URLWithString:BS_UNSUPPORTED_STRATEGY_JSON_URL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (!data.length) {
        NSError *err = [NSError errorWithDomain:BSCStrategyErrorDomain
                                           code:BSCS_ERROR_MANIFEST_DOWNLOAD
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
        err = [NSError errorWithDomain:BSCStrategyErrorDomain
                                             code:BSCS_ERROR_MANIFEST_PARSE
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

- (NSURL *)createExportFolder:(NSURL *)folderUrl {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSString *basePath = [folderUrl.path stringByAppendingPathComponent:STRATEGY_FOLDER_NAME];
    NSUInteger counter = 0;
    NSError *err;
    NSString *newPath = basePath;
    while (![fm createDirectoryAtPath:newPath
         withIntermediateDirectories:NO
                          attributes:nil
                               error:&err] && counter < STRATEGY_FOLDER_NAME_COUNTER_MAX) {
        counter++;
        newPath = [NSString stringWithFormat:@"%@-%lu", basePath, (unsigned long)counter];
        err = nil;
    }
    if (err) {
        DDLogError(@"Error creating folder for downloading of a strategies: %@", err);
        return  nil;
    }
    
    return [NSURL fileURLWithPath:newPath];
}

@end
