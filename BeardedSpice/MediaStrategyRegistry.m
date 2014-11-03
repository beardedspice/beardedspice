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
#import "GoogleMusicStrategy.h"
#import "RdioStrategy.h"
#import "EightTracksStrategy.h"
#import "SynologyStrategy.h"
#import "ShufflerFmStrategy.h"
#import "SongzaStrategy.h"
#import "SlackerStrategy.h"
#import "BeatsMusicStrategy.h"
#import "MixCloudStrategy.h"
#import "MusicUnlimitedStrategy.h"
#import "YandexMusicStrategy.h"
#import "StitcherStrategy.h"
#import "XboxMusicStrategy.h"
#import "VkStrategy.h"
#import "BopFm.h"
#import "AmazonMusicStrategy.h"
#import "OvercastStrategy.h"
#import "VimeoStrategy.h"

@implementation MediaStrategyRegistry

-(id) init
{
    self = [super init];
    if (self)
    {
        availableStrategies = [NSMutableArray new];
    }
    return self;
}

-(id) initWithUserDefaults:(NSString *)userDefaultsKey
{
    self = [self init];
    if (self) {
        NSArray *defaultStrategies = [MediaStrategyRegistry getDefaultMediaStrategies];
        NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:userDefaultsKey];

        for (MediaStrategy *strategy in defaultStrategies) {
            NSNumber *enabled = [defaults objectForKey:[strategy displayName]];
            if ([enabled intValue] == 1) {
                [self addMediaStrategy:strategy];
            }
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
    return [availableStrategies copy];
}

+(NSArray *) getDefaultMediaStrategies
{
    static dispatch_once_t setupDefaultStrategies;
    static NSArray *strategies = nil;

    dispatch_once(&setupDefaultStrategies, ^{
        NSLog(@"Initializing default media strategies...");
        strategies = @[
                        [YouTubeStrategy new],
                        [PandoraStrategy new],
                        [BandCampStrategy new],
                        [GrooveSharkStrategy new],
                        [HypeMachineStrategy new],
                        [SoundCloudStrategy new],
                        [LastFmStrategy new],
                        [SpotifyStrategy new],
                        [GoogleMusicStrategy new],
                        [RdioStrategy new],
                        [EightTracksStrategy new],
                        [SynologyStrategy new],
                        [ShufflerFmStrategy new],
                        [SongzaStrategy new],
                        [SlackerStrategy new],
                        [BeatsMusicStrategy new],
                        [MixCloudStrategy new],
                        [MusicUnlimitedStrategy new],
                        [YandexMusicStrategy new],
                        [StitcherStrategy new],
                        [XboxMusicStrategy new],
                        [VkStrategy new],
                        [BopFm new],
                        [AmazonMusicStrategy new],
                        [OvercastStrategy new],
                        [VimeoStrategy new]
                    ];
    });
    return strategies;
}

+(id) getDefaultRegistry
{
    MediaStrategyRegistry *registry = [[MediaStrategyRegistry alloc] init];
    [registry addMediaStrategies:[MediaStrategyRegistry getDefaultMediaStrategies]];
    return registry;
}


@end
