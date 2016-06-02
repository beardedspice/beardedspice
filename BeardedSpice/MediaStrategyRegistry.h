//
//  MediaStrategyRegistry.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

@class BSMediaStrategy;
@class TabAdapter;
@class BSStrategyCache;

@interface MediaStrategyRegistry : NSObject
@property (nonatomic, strong, readonly) BSStrategyCache *strategyCache;

-(instancetype)initWithUserDefaults:(NSString *)userDefaultsKey strategyCache:(BSStrategyCache *)cache;

-(void) addMediaStrategy:(BSMediaStrategy *) strategy;
-(void) removeMediaStrategy:(BSMediaStrategy *) strategy;
-(void) containsMediaStrategy:(BSMediaStrategy *) strategy;
-(BSMediaStrategy *) getMediaStrategyForTab:(TabAdapter *) tab;

- (void)clearCache;
- (void)beginStrategyQueries;
- (void)endStrategyQueries;

@end
