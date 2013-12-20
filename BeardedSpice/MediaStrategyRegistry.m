//
//  MediaStrategyRegistry.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategyRegistry.h"
#import "YouTubeStrategy.h"
#import "PandoraStrategy.h"
#import "BandCampStrategy.h"
#import "GrooveSharkStrategy.h"
#import "SoundCloudStrategy.h"
#import "HypeMachineStrategy.h"

@implementation MediaStrategyRegistry

-(id) init
{
    self = [super init];
    if (self) {
        availableStrategies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies addObject:strategy];
}

-(void) removeMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies removeObject:strategy];
}

-(void) containsMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies containsObject:strategy];
}
     
-(MediaStrategy *) getMediaStrategyForTab:(id<Tab>)tab
{

    for (MediaStrategy *strategy in availableStrategies) {
        if ([strategy accepts:tab]) {
            NSLog(@"%@ is valid for %@", strategy, tab);
            return strategy;
        }
    }
    return NULL;
}

+(id) addDefaultMediaStrategies:(MediaStrategyRegistry *) registry
{
    [registry addMediaStrategy:[[YouTubeStrategy alloc] init]];
    [registry addMediaStrategy:[[PandoraStrategy alloc] init]];
    [registry addMediaStrategy:[[BandCampStrategy alloc] init]];
    [registry addMediaStrategy:[[GrooveSharkStrategy alloc] init]];
    [registry addMediaStrategy:[[HypeMachineStrategy alloc] init]];
    [registry addMediaStrategy:[[SoundCloudStrategy alloc] init]];
    return registry;
}

+(id) getDefaultRegistry
{
    return [MediaStrategyRegistry addDefaultMediaStrategies:[[MediaStrategyRegistry alloc] init]];
}


@end
