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
#import "EHExecuteBlockDelayed.h"

#define MAX_REGISTERED_CACHE            500
#define NOTOFICATION_RELAX_TIMEOUT      2 //seconds

NSString *BSMediaStrategyRegistryChangedNotification = @"BSMediaStrategyRegistryChangedNotification";

@interface MediaStrategyRegistry ()
@property (nonatomic) NSMutableArray *availableStrategies;
@property (nonatomic) BSStrategyCache *strategyCache;
@end

@implementation MediaStrategyRegistry {
    BOOL _massChanging;
    BOOL _changed;
    EHExecuteBlockDelayed *_notifyRelaxer;
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
    _massChanging = _changed = NO;
    
    _notifyRelaxer = [[EHExecuteBlockDelayed alloc] initWithTimeout:NOTOFICATION_RELAX_TIMEOUT
                                                       leeway:NOTOFICATION_RELAX_TIMEOUT
                                                        queue:dispatch_get_main_queue()
                                                        block:^{
        if (self->_massChanging) {
            self->_changed = YES;
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:BSMediaStrategyRegistryChangedNotification object:self];
        }
    }];
    
    return self;
}

- (void)setUserDefaults:(NSString *)userDefaultsKey strategyCache:(BSStrategyCache *)cache
{
    _strategyCache = cache;
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
- (void)beginChangingAvailableMediaStrategies {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_massChanging = YES;
    });
}

- (void)endChangingAvailableMediaStrategies {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_massChanging && self->_changed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BSMediaStrategyRegistryChangedNotification object:self];
        }
        self->_massChanging = self->_changed = NO;
    });
}

-(void) addAvailableMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies addObject:strategy];
    [_notifyRelaxer executeOnceAfterCalm];
}

-(void) removeAvailableMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies removeObject:strategy];
    [_notifyRelaxer executeOnceAfterCalm];
}

@end
