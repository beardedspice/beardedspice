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

@protocol BSStrategyCacheDelegateProtocol <NSObject>

@required
- (void)didChangeStrategy:(BSMediaStrategy *_Nonnull)strategy;
- (void)didAddStrategy:(BSMediaStrategy *_Nonnull)strategy;
- (void)didDeleteStrategy:(BSMediaStrategy *_Nonnull)strategy;

@end


@interface BSStrategyCache : NSObject

- (instancetype _Nullable )initWithDelegate:(id<BSStrategyCacheDelegateProtocol> _Nonnull)delegate;

@property (weak) id<BSStrategyCacheDelegateProtocol> _Nullable delegate;

/**
 FIXME documentation about loading strategies and how they're cached
 */
- (BOOL)loadStrategies;

/**
 FIXME documentation
 */
- (BOOL)updateStrategiesFromSourceURL:(NSURL * _Nonnull)path;

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
- (void)removeStrategyFromCache:(BSMediaStrategy * _Nonnull)strategy;

/**
 Fetches the loaded strategies for reuse and requerying without hitting the disk.
 @param strategyName the name of the strategy file to be accessed. Case Sensitive.
 @returns A reference to the cached BSMediaStrategy object associated with the given strategyName
 */
- (BSMediaStrategy * _Nullable)strategyForFileName:(NSString * _Nonnull)strategyName;

@end
