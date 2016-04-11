//
//  MediaStrategyRegistry.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategyRegistry.h"

@interface MediaStrategyRegistry ()
@property (nonatomic, strong) NSMutableDictionary *registeredCache;
@property (nonatomic, strong) NSMutableSet *keyCache;
@property (nonatomic, strong) NSArray *ioc_MediaStrategyProtocol;
@end

@implementation MediaStrategyRegistry

-(id) init
{
    self = [super init];
    if (self)
    {
        self.registeredCache = [NSMutableDictionary dictionary];
        availableStrategies = [NSMutableArray array];
    }
    return self;
}

-(id) initWithUserDefaults:(NSString *)userDefaultsKey
{
    self = [self init];
    if (self) {
        NSArray *defaultStrategies = self.ioc_MediaStrategyProtocol;
        NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:userDefaultsKey];

        for (MediaStrategy *strategy in defaultStrategies) {
            NSNumber *enabled = [defaults objectForKey:[strategy displayName]];
            if (!enabled || [enabled boolValue]) {
                [self addMediaStrategy:strategy];
            }
        }
    }
    return self;
}

-(void) addMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies addObject:strategy];
    [self clearCache];
}

-(void) removeMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies removeObject:strategy];
    [self clearCache];
}

-(void) containsMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies containsObject:strategy];
}

- (void)clearCache
{
    self.registeredCache = [NSMutableDictionary dictionary];
}

- (void)beginStrategyQueries
{
    self.keyCache = [NSMutableSet setWithArray:[_registeredCache allKeys]];
}

- (void)endStrategyQueries
{
    /* Clean the cache of tabs that dont exist anymore */
    NSSet *updatedKeys = [NSSet setWithArray:[_registeredCache allKeys]];
    [_keyCache minusSet:updatedKeys];
    [_registeredCache removeObjectsForKeys:[_keyCache allObjects]];

    self.keyCache = nil;
}

-(MediaStrategy *) getMediaStrategyForTab:(TabAdapter *)tab
{
    if (tab.check) {

        NSString *cacheKey = [NSString stringWithFormat:@"%@", tab.URL];
        MediaStrategy *strat = _registeredCache[cacheKey];
        if (strat)
        /* Return the equivalent of a full scan except we dont repeat calculations */
        return [strat isKindOfClass:[MediaStrategy class]] ? strat : NULL;

        for (MediaStrategy *strategy in availableStrategies)
        {
            BOOL accepted = [strategy accepts:tab];

            /* Store the result of this calculation for future use */
            _registeredCache[cacheKey] = accepted ? strategy : @NO;
            if (accepted) {
                NSLog(@"%@ is valid for %@", strategy, tab);
                return strategy;
            }
        }
    }
    return nil;
}

-(NSArray *) getMediaStrategies
{
    return [availableStrategies copy];
}

@end
