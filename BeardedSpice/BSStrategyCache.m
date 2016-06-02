//
//  BSStrategyCache.m
//  BeardedSpice
//
//  Created by Alex Evers on 05/28/2016
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyCache.h"
#import "BSMediaStrategy.h"

@interface BSStrategyCache ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, BSMediaStrategy *> *cache;
@property (nonatomic, strong) dispatch_queue_t cacheSerialQueue;
@end

@implementation BSStrategyCache

+ (BSStrategyCache * _Nonnull)strategyCache
{
    static dispatch_once_t setupCache;
    static BSStrategyCache *strategyCache = nil;

    dispatch_once(&setupCache, ^{
        strategyCache = [BSStrategyCache new];
    });

    return strategyCache;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // this is a dictionary instead of NSCache for extra add/remove functions.
        // Plus we don't want this to randomly get garbage collected
        _cache = [NSMutableDictionary new];
        _cacheSerialQueue = dispatch_queue_create("com.beardedspice.cache.strategies.serial", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSArray<NSString *> *)allKeys
{
    return [self.cache allKeys];
}

- (void)removeStrategyFromCache:(NSString * _Nonnull)strategyName
{
    __weak typeof(self) wself = self;
    dispatch_sync(_cacheSerialQueue, ^{
        // make a new strong pointer to this obj
        __strong typeof(wself) sself = wself;
        [sself.cache removeObjectForKey:strategyName];
    });
}

- (void)updateCacheWithURL:(NSURL * _Nonnull)strategyURL
{
    __weak typeof(self) wself = self;
    dispatch_sync(_cacheSerialQueue, ^{
        // make a new strong pointer to this obj
        __strong typeof(wself) sself = wself;
        [sself _updateCacheWithURL:strategyURL];
    });
}

- (void)_updateCacheWithURL:(NSURL *_Nonnull)strategyURL
{
    NSString *fileName = [strategyURL lastPathComponent];
    BSMediaStrategy *strategy = [_cache objectForKey:fileName];
    if (strategy)
        [strategy reloadDataFromURL:strategyURL];
    else
        _cache[fileName] = [[BSMediaStrategy alloc] initWithStrategyURL:strategyURL];
}

- (BSMediaStrategy * _Nullable)strategyForName:(NSString * _Nonnull)strategyName
{
    return _cache[strategyName];
}

@end
