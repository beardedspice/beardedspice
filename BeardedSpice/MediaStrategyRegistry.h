//
//  MediaStrategyRegistry.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

@class BSMediaStrategy;
@class TabAdapter;

@interface MediaStrategyRegistry : NSObject
@property (nonatomic, strong) NSMutableArray *availableStrategies;

+(NSArray<NSString *> *)getDefaultMediaStrategyNames;

-(id) initWithUserDefaults:(NSString *)userDefaultsKeyPrefix;
-(void) addMediaStrategy:(BSMediaStrategy *) strategy;
-(void) removeMediaStrategy:(BSMediaStrategy *) strategy;
-(void) containsMediaStrategy:(BSMediaStrategy *) strategy;
-(BSMediaStrategy *) getMediaStrategyForTab:(TabAdapter *) tab;
-(NSArray *) getMediaStrategies;

- (void)clearCache;
- (void)beginStrategyQueries;
- (void)endStrategyQueries;

@end
