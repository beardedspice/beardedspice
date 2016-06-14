//
//  MediaStrategyRegistry.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategyRegistry.h"
#import "BSMediaStrategy.h"
#import "BSStrategyCache.h"
#import "TabAdapter.h"

@interface MediaStrategyRegistry ()
@property (nonatomic, strong) NSMutableArray *availableStrategies;
@property (nonatomic, strong) NSMutableDictionary *registeredCache;
@property (nonatomic, strong) NSMutableSet *keyCache;
@property (nonatomic, strong) BSStrategyCache *strategyCache;
@end

@implementation MediaStrategyRegistry

static MediaStrategyRegistry *singletonMediaStrategyRegistry;

/////////////////////////////////////////////////////////////////////
#pragma mark Initialize

+ (MediaStrategyRegistry *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonMediaStrategyRegistry = [MediaStrategyRegistry alloc];
        singletonMediaStrategyRegistry = [singletonMediaStrategyRegistry init];
    });
    
    return singletonMediaStrategyRegistry;
    
}

- (id)init{
    
    if (singletonMediaStrategyRegistry != self) {
        return nil;
    }
    self = [super init];

    return self;
}

- (void)setUserDefaults:(NSString *)userDefaultsKey strategyCache:(BSStrategyCache *)cache
{
    _strategyCache = cache;
    _registeredCache = [NSMutableDictionary new];
    _availableStrategies = [NSMutableArray new];
    
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:userDefaultsKey];
    
    // enable strategies that are marked enabled or have no entry
    for (NSString *fileName in _strategyCache.cache)
    {
        BSMediaStrategy *strategy = _strategyCache.cache[fileName];
        NSNumber *enabled = [defaults objectForKey:[strategy displayName]];
        if (!enabled || [enabled boolValue]) {
            [self addMediaStrategy:strategy];
        }
    }
}

/////////////////////////////////////////////////////////////////////
#pragma mark Methods

-(void) addMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies addObject:strategy];
    [self clearCache];
}

-(void) removeMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies removeObject:strategy];
    [self clearCache];
}

-(void) containsMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies containsObject:strategy];
}

- (void)clearCache
{
    if (_registeredCache.count)
        self.registeredCache = [NSMutableDictionary dictionary];
}

- (void)beginStrategyQueries
{
    self.keyCache = [NSMutableSet setWithArray:[_registeredCache allKeys]];
}

- (void)endStrategyQueries
{
    if (!_keyCache)
    {
        NSLog(@"WARNING - Strategy Queries not started.");
        return;
    }

    /* Clean the cache of tabs that dont exist anymore */
    NSSet *updatedKeys = [NSSet setWithArray:[_registeredCache allKeys]];
    [_keyCache minusSet:updatedKeys];
    [_registeredCache removeObjectsForKeys:[_keyCache allObjects]];

    self.keyCache = nil;
}

- (BSMediaStrategy *)getMediaStrategyForTab:(TabAdapter *)tab
{
    if (!tab.check)
        return nil;

    NSString *cacheKey = [NSString stringWithFormat:@"%@", [tab URL]];
    id strat = _registeredCache[cacheKey];

    /* Return the equivalent of a full scan except we dont repeat calculations */
    if (strat == [NSNull null])
        return nil;
    if (strat)
        return strat;

    for (BSMediaStrategy *strategy in _availableStrategies)
    {
        BOOL accepted = [strategy accepts:tab];

        /* Store the result of this calculation for future use */
        if (accepted)
        {
            _registeredCache[cacheKey] = strategy;
            NSLog(@"%@ is valid for %@", strategy, tab);
            return strategy;
        }
    }
    /* Worst case, no compatible registry found */
    _registeredCache[cacheKey] = [NSNull null];
    return nil;
}

@end
