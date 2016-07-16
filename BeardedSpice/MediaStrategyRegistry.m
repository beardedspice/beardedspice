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
@property (nonatomic, strong) BSStrategyCache *strategyCache;
@property (nonatomic) NSCompoundPredicate *commonAcceptPredicate;
@property (nonatomic) NSString *commonAcceptScript;

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
    _registeredCache = [NSMutableDictionary new];
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
    
    [self reloadCommonAccept];
}

/////////////////////////////////////////////////////////////////////
#pragma mark Methods

-(void) addMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies addObject:strategy];
    [self clearCache];
    [self reloadCommonAccept];
}

-(void) removeMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies removeObject:strategy];
    [self clearCache];
    [self reloadCommonAccept];
}

- (void)clearCache
{
    if (_registeredCache.count)
        self.registeredCache = [NSMutableDictionary dictionary];
}

- (void)reloadCommonAccept {

    @autoreleasepool {

        NSMutableArray<NSPredicate *> *predicates = [NSMutableArray new];
        NSMutableArray<NSString *> *scripts = [NSMutableArray new];
        for (BSMediaStrategy *item in self.availableStrategies) {

            NSString *method = item.acceptParams[kBSMediaStrategyAcceptMethod];
            if (!method)
                continue;

            if ([method isEqualToString:kBSMediaStrategyAcceptPredicateOnTab]) {
                NSPredicate *acceptPredicate = item.acceptParams[kBSMediaStrategyKeyAccept];
                if (acceptPredicate) {
                    [predicates addObject:acceptPredicate];
                }
            } else if ([method isEqualToString:kBSMediaStrategyAcceptScript]) {
                NSString *acceptScript = item.acceptParams[kBSMediaStrategyKeyAccept];
                if (acceptScript) {
                    [scripts addObject:acceptScript];
                }
            }
        }
        
        if (predicates.count) {
            self.commonAcceptPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
        }
        else
            self.commonAcceptPredicate = nil;
        
        if (scripts.count) {
            self.commonAcceptScript = [NSString stringWithFormat:@"(function(){return (%@)})();", [scripts componentsJoinedByString:@" || "]];
        }
        else
            self.commonAcceptScript = nil;
    }
}

- (BSMediaStrategy *)getMediaStrategyForTab:(TabAdapter *)tab {

    NSString *cacheKey = [NSString stringWithFormat:@"%@", [tab URL]];
    id strat = _registeredCache[cacheKey];

    /* Return the equivalent of a full scan except we dont repeat calculations */
    if (strat == [NSNull null])
        return nil;
    if (strat)
        return strat;

    BOOL commonCheck = NO;
    if (self.commonAcceptPredicate) {
        
        commonCheck = [self.commonAcceptPredicate evaluateWithObject:tab];
    }
    if (tab.check) {

        if (!commonCheck && self.commonAcceptScript) {
            
            commonCheck = [[tab executeJavascript:self.commonAcceptScript] boolValue];
        }
        if (commonCheck) {
            
            for (BSMediaStrategy *strategy in _availableStrategies) {
                BOOL accepted = [strategy accepts:tab];
                
                /* Store the result of this calculation for future use */
                if (accepted) {
                    _registeredCache[cacheKey] = strategy;
                    NSLog(@"%@ is valid for %@", strategy, tab);
                    return strategy;
                }
            }
        }
    }
    /* Worst case, no compatible registry found */
    _registeredCache[cacheKey] = [NSNull null];
    return nil;
}

@end
