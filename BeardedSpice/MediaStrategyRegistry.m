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
#import "LastFmStrategy.h"
#import "SpotifyStrategy.h"

NSArray * DefaultMediaStrategies;

@implementation MediaStrategyRegistry

-(id) init
{
    self = [super init];
    if (self) {
        availableStrategies = [[NSMutableArray alloc] init];
    }
    return self;
}

// TODO JF: bah copypasta
-(id) initWithUserDefaults:(NSString *)userDefaultsKey
{
    self = [super init];
    if (self) {
        availableStrategies = [[NSMutableArray alloc] init];
    }

    NSArray *defaultStrategies = [MediaStrategyRegistry getDefaultMediaStrategies];
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:userDefaultsKey];

    for (MediaStrategy *strategy in defaultStrategies) {
        NSNumber *enabled = [defaults objectForKey:[strategy displayName]];
        if ([enabled intValue] == 1) {
            [self addMediaStrategy:strategy];
        }
    }

    return self;
}

-(void) addMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies addObject:strategy];
}

-(void) addMediaStrategies:(NSArray *)strategies
{
    [availableStrategies addObjectsFromArray:strategies];
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

-(NSArray *) getMediaStrategies
{
    return [NSArray arrayWithArray:availableStrategies];
}

+(NSArray *) getDefaultMediaStrategies
{
    if (!DefaultMediaStrategies) {
        NSLog(@"Initializing default media strategies...");
        DefaultMediaStrategies = [NSArray arrayWithObjects:
                                  [[YouTubeStrategy alloc] init],
                                  [[PandoraStrategy alloc] init],
                                  [[BandCampStrategy alloc] init],
                                  [[GrooveSharkStrategy alloc] init],
                                  [[HypeMachineStrategy alloc] init],
                                  [[SoundCloudStrategy alloc] init],
                                  [[LastFmStrategy alloc] init],
                                  [[SpotifyStrategy alloc] init],
                                  nil];
    }
    return DefaultMediaStrategies;
}

+(id) getDefaultRegistry
{
    MediaStrategyRegistry *registry = [[MediaStrategyRegistry alloc] init];
    [registry addMediaStrategies:[MediaStrategyRegistry getDefaultMediaStrategies]];
    return registry;
}


@end
