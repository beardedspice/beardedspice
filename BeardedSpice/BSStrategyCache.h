//
//  BSStrategyCache.h
//  BeardedSpice
//
//  Created by Alex Evers on 05/28/2016
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

@class BSMediaStrategy;

@interface BSStrategyCache : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, BSMediaStrategy *> * _Nonnull cache;

/**
 Singleton accessor for strategy cache object.
 @return a singleton instance of BSStrategyCache
 */
+ (BSStrategyCache * _Nonnull)strategyCache;

- (NSArray<NSString *> * _Nonnull)allKeys;

/**
 Updates or addes the strategy at the given URL to the object's cache.
 @param strategyURL the URL which contains the strategy data
 */
- (void)updateCacheWithURL:(NSURL * _Nonnull)strategyURL;

/**
 FIXME simple remove docs
 */
- (void)removeStrategyFromCache:(NSString * _Nonnull)strategyName;

/**
 Fetches the loaded strategies for reuse and requerying without hitting the disk.
 @param strategyName the name of the strategy file to be accessed. Case Sensitive.
 @returns A reference to the cached BSMediaStrategy object associated with the given strategyName
 */
- (BSMediaStrategy * _Nullable)strategyForName:(NSString * _Nonnull)strategyName;

@end
