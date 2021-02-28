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
    
    return self;
}

- (void)setUserDefaults:(NSString *)userDefaultsKey
{
    [self beginChangingAvailableMediaStrategies];
    
    _strategyCache = [[BSStrategyCache alloc] initWithDelegate:self];
    
    [_strategyCache loadStrategies];

    _availableStrategies = [NSMutableArray new];

    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:userDefaultsKey];

    // enable strategies that are marked enabled or have no entry
    for (BSMediaStrategy *strategy in _strategyCache.allStrategies)
    {
        NSNumber *enabled = [defaults objectForKey:[strategy displayName]];
        if (!enabled || [enabled boolValue]) {
            [_availableStrategies addObject:strategy];
        }
    }
    
    [self endChangingAvailableMediaStrategies];
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
    [self notify];
}

-(void) removeAvailableMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies removeObject:strategy];
    [self notify];
}
- (void)notify {
    static EHExecuteBlockDelayed *notifyRelaxer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notifyRelaxer = [[EHExecuteBlockDelayed alloc] initWithTimeout:NOTOFICATION_RELAX_TIMEOUT
                                                           leeway:NOTOFICATION_RELAX_TIMEOUT
                                                            queue:dispatch_get_main_queue()
                                                            block:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BSMediaStrategyRegistryChangedNotification object:self];
        }];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_massChanging) {
            self->_changed = YES;
        }
        else {
            [notifyRelaxer executeOnceAfterCalm];
        }
    });

}
/////////////////////////////////////////////////////////////////////
#pragma mark BSStrategyCacheDelegateProtocol implementation

- (void)didAddStrategy:(BSMediaStrategy * _Nonnull)strategy {
    [self addAvailableMediaStrategy:strategy];
}

- (void)didChangeStrategy:(BSMediaStrategy * _Nonnull)strategy {
    [self notify];
}

- (void)didDeleteStrategy:(BSMediaStrategy * _Nonnull)strategy {
    [self removeAvailableMediaStrategy:strategy];
}

@end
