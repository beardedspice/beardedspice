//
//  BSStrategyCache.h
//  BeardedSpice
//
//  Created by Alex Evers on 05/28/2016
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

@class BSMediaStrategy;

extern NSString * _Nonnull BSStrategyCacheErrorDomain;
#define BSSC_ERROR_STRATEGY_NOTFOUND            100

@interface BSStrategyCache : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, BSMediaStrategy *> * _Nonnull cache;

/**
 FIXME documentation about loading strategies and how they're cached
 */
- (BOOL)loadStrategies;

/**
 FIXME documentation
 */
- (BOOL)updateStrategiesFromSourceURL:(NSURL * _Nonnull)path;

/**
 FIXME documentation
 */
- (NSArray<NSString *> * _Nonnull)allKeys;

/**
 */
- (NSArray <BSMediaStrategy *> * _Nonnull)allStrategies;

/**
 Updates the strategy at the given URL to the object's cache.
 @param strategyURL the URL which contains the strategy data
 */
- (NSError * _Nullable)updateStrategyWithURL:(NSURL * _Nonnull)strategyURL;

/**
 Addes the strategy at the given URL to the object's cache.
 @param strategyURL the URL which contains the strategy data
 @return Returns BSMediaStrategy object, which was added or nil if failure.
 */
- (BSMediaStrategy * _Nullable)addStrategyWithURL:(NSURL * _Nonnull)strategyURL;

/**
 FIXME simple remove docs
 */
- (void)removeStrategyFromCache:(NSString * _Nonnull)strategyName;

/**
 Fetches the loaded strategies for reuse and requerying without hitting the disk.
 @param strategyName the name of the strategy file to be accessed. Case Sensitive.
 @returns A reference to the cached BSMediaStrategy object associated with the given strategyName
 */
- (BSMediaStrategy * _Nullable)strategyForFileName:(NSString * _Nonnull)strategyName;

@end
