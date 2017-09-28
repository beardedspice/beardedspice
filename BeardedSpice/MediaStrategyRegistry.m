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
#import "EHCCache.h"

#define MAX_REGISTERED_CACHE            500

NSString *BSMediaStrategyRegistryChangedNotification = @"BSMediaStrategyRegistryChangedNotification";

@interface MediaStrategyRegistry ()
@property (nonatomic) NSMutableArray *availableStrategies;
@property (nonatomic) EHCCache *registeredCache;
@property (nonatomic) BSStrategyCache *strategyCache;
@end

@implementation MediaStrategyRegistry {
}

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
    _registeredCache = [[EHCCache alloc] initWithCapacity:MAX_REGISTERED_CACHE];
    _availableStrategies = [NSMutableArray new];

    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:userDefaultsKey];

    // enable strategies that are marked enabled or have no entry
    for (NSString *fileName in _strategyCache.cache)
    {
        BSMediaStrategy *strategy = _strategyCache.cache[fileName];
        NSNumber *enabled = [defaults objectForKey:[strategy displayName]];
        if (!enabled || [enabled boolValue]) {
            [_availableStrategies addObject:strategy];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BSMediaStrategyRegistryChangedNotification object:self];
    });
}

/////////////////////////////////////////////////////////////////////
#pragma mark Methods

-(void) addMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies addObject:strategy];
    [self.registeredCache clear];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BSMediaStrategyRegistryChangedNotification object:self];
    });
}

-(void) removeMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies removeObject:strategy];
    [self.registeredCache clear];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BSMediaStrategyRegistryChangedNotification object:self];
    });
}

- (BSMediaStrategy *)getMediaStrategyForTab:(TabAdapter *)tab {
    if (tab == nil)
        return nil;

    NSString *cacheKey = [NSString stringWithFormat:@"%@", [tab URL]];
    id strat = self.registeredCache[cacheKey];

    /* Return the equivalent of a full scan except we dont repeat calculations */
    if (strat == [NSNull null])
        return nil;
    if (strat)
        return strat;

    if (tab.check) {

        for (BSMediaStrategy *strategy in _availableStrategies) {
            BOOL accepted = [strategy accepts:tab];

            /* Store the result of this calculation for future use */
            if (accepted) {
                [self.registeredCache addValue:strategy forKey:cacheKey];
                NSLog(@"%@ is valid for %@", strategy, tab);
                return strategy;
            }
        }
    }
    /* Worst case, no compatible registry found */
    [self.registeredCache addValue:[NSNull null] forKey:cacheKey];
    return nil;
}

@end
