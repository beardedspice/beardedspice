//
//  MediaStrategyRegistry.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategyRegistry.h"
#import "LogitechMediaServerStrategy.h"
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
#import "ChorusStrategy.h"
#import "TwentyTwoTracksStrategy.h"
#import "AudioMackStrategy.h"
#import "DeezerStrategy.h"
#import "FocusAtWillStrategy.h"
#import "PocketCastsStrategy.h"
#import "TidalHiFiStrategy.h"
#import "NoAdRadioStrategy.h"
#import "SomaFmStrategy.h"
#import "DigitallyImportedStrategy.h"
#import "BeatguideStrategy.h"
#import "SaavnStrategy.h"
#import "KollektFmStrategy.h"
#import "WonderFmStrategy.h"
#import "OdnoklassnikiStrategy.h"

@interface MediaStrategyRegistry ()
@property (nonatomic, strong) NSMutableDictionary *registeredCache;
@property (nonatomic, strong) NSMutableSet *keyCache;
@end

@implementation MediaStrategyRegistry

-(id) init
{
    self = [super init];
    if (self)
    {
        self.registeredCache = [NSMutableDictionary dictionary];
        availableStrategies = [NSMutableArray array];
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
    [self clearCache];
}

-(void) removeMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies removeObject:strategy];
    [self clearCache];
}

-(void) containsMediaStrategy:(MediaStrategy *) strategy
{
    [availableStrategies containsObject:strategy];
}

- (void)clearCache
{
    self.registeredCache = [NSMutableDictionary dictionary];
}

- (void)beginStrategyQueries
{
    self.keyCache = [NSMutableSet setWithArray:[_registeredCache allKeys]];
}

- (void)endStrategyQueries
{
    /* Clean the cache of tabs that dont exist anymore */
    NSSet *updatedKeys = [NSSet setWithArray:[_registeredCache allKeys]];
    [_keyCache minusSet:updatedKeys];
    [_registeredCache removeObjectsForKeys:[_keyCache allObjects]];

    self.keyCache = nil;
}

-(MediaStrategy *) getMediaStrategyForTab:(TabAdapter *)tab
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@", tab.URL];
    MediaStrategy *strat = _registeredCache[cacheKey];
    if (strat)
        /* Return the equivalent of a full scan except we dont repeat calculations */
        return [strat isKindOfClass:[MediaStrategy class]] ? strat : NULL;

    for (MediaStrategy *strategy in availableStrategies)
    {
        BOOL accepted = [strategy accepts:tab];

        /* Store the result of this calculation for future use */
        _registeredCache[cacheKey] = accepted ? strategy : @NO;
        if (accepted) {
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
                        [LogitechMediaServerStrategy new],
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
                        [VimeoStrategy new],
                        [ChorusStrategy new],
                        [TwentyTwoTracksStrategy new],
                        [AudioMackStrategy new],
                        [DeezerStrategy new],
                        [FocusAtWillStrategy new],
                        [PocketCastsStrategy new],
                        [TidalHiFiStrategy new],
                        [NoAdRadioStrategy new],
                        [SomaFmStrategy new],
                        [DigitallyImportedStrategy new],
                        [BeatguideStrategy new],
                        [SaavnStrategy new],
                        [KollektFmStrategy new],
                        [WonderFmStrategy new],
                        [OdnoklassnikiStrategy new]
                    ];
    });
    return strategies;
}

@end
