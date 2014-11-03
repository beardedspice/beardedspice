//
//  MediaStrategyRegistry.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaStrategy.h"

@interface MediaStrategyRegistry : NSObject
{
    NSMutableArray *availableStrategies;
}

+(id) getDefaultRegistry;
+(NSArray *) getDefaultMediaStrategies;

-(id) initWithUserDefaults:(NSString *)userDefaultsKeyPrefix;
-(void) addMediaStrategy:(MediaStrategy *) strategy;
-(void) addMediaStrategies:(NSArray *) strategies;
-(void) removeMediaStrategy:(MediaStrategy *) strategy;
-(void) containsMediaStrategy:(MediaStrategy *) strategy;
-(MediaStrategy *) getMediaStrategyForTab:(id <Tab>) tab;
-(NSArray *) getMediaStrategies;

- (void)clearCache;
- (void)beginStrategyQueries;
- (void)endStrategyQueries;

@end
