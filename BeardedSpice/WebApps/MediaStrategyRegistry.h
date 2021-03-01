//
//  MediaStrategyRegistry.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
#import "BSStrategyCache.h"

@class BSMediaStrategy;
@class TabAdapter;

extern NSString *BSMediaStrategyRegistryChangedNotification;
extern NSString *BSMediaStrategyRegistryChangedNotificationUserInfoKey_Silent; // Value is NSNumber boolean object

@interface MediaStrategyRegistry : NSObject <BSStrategyCacheDelegateProtocol>

+ (MediaStrategyRegistry *)singleton;

@property (nonatomic, readonly) BSStrategyCache *strategyCache;
@property (nonatomic, readonly) NSMutableArray *availableStrategies;

/**
 Resets registry.
 */
- (void)setUserDefaults:(NSString *)userDefaultsKey;

- (void)beginChangingAvailableMediaStrategies;
- (void)endChangingAvailableMediaStrategies:(BOOL)silentNotify;

-(void) addAvailableMediaStrategy:(BSMediaStrategy *) strategy;
-(void) removeAvailableMediaStrategy:(BSMediaStrategy *) strategy;

@end
