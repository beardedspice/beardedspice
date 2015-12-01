//
//  MediaStrategyRegistry.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategyRegistry.h"
#import "BSMediaStrategy.h"
#import "TabAdapter.h"

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
        _registeredCache = [NSMutableDictionary new];
        _availableStrategies = [NSMutableArray new];
    }
    return self;
}

-(id) initWithUserDefaults:(NSString *)userDefaultsKey
{
    self = [self init];
    if (self) {
        NSArray<NSString *> *defaultStrategies = [MediaStrategyRegistry getDefaultMediaStrategyNames];
        NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:userDefaultsKey];

        // enable strategies that are marked enabled or have no entry
        for (NSString *name in defaultStrategies) {
            BSMediaStrategy *strategy = [BSMediaStrategy cacheForStrategyName:name];
            NSNumber *enabled = [defaults objectForKey:[strategy displayName]];
            if (!enabled || [enabled boolValue]) {
                [self addMediaStrategy:strategy];
            }
        }
    }
    return self;
}

-(void) addMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies addObject:strategy];
    [self clearCache];
}

-(void) removeMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies removeObject:strategy];
    [self clearCache];
}

-(void) containsMediaStrategy:(BSMediaStrategy *) strategy
{
    [_availableStrategies containsObject:strategy];
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

-(BSMediaStrategy *) getMediaStrategyForTab:(TabAdapter *)tab
{
    if (tab.check) {

        NSString *cacheKey = [NSString stringWithFormat:@"%@", tab.URL];
        BSMediaStrategy *strat = _registeredCache[cacheKey];
        if (strat)
        /* Return the equivalent of a full scan except we dont repeat calculations */
        return [strat isKindOfClass:[MediaStrategy class]] ? strat : NULL;

<<<<<<< 38581355b6628cde6b1d30b9bbd7a6609075ddf9
        for (MediaStrategy *strategy in availableStrategies)
=======
        for (BSMediaStrategy *strategy in _availableStrategies)
>>>>>>> Replaced MediaStrategies implementations with content plists containing relevant data.
        {
            BOOL accepted = [strategy accepts:tab];

            /* Store the result of this calculation for future use */
            _registeredCache[cacheKey] = accepted ? strategy : @NO;
            if (accepted) {
                NSLog(@"%@ is valid for %@", strategy, tab);
                return strategy;
            }
        }
    }
    return nil;
}

-(NSArray *) getMediaStrategies
{
    return [_availableStrategies copy];
}

// FIXME make this cache somehow. we don't want to hit the disk every time.
+(NSArray<NSString *> *)getDefaultMediaStrategyNames
{
    NSURL *versionPath = [NSURL versionsFileFromURL];
    if (![versionPath fileExists]) // failover in case we dont have a mutable index file yet.
        versionPath = [[NSBundle mainBundle] URLForResource:@"versions" withExtension:@"plist"];

    NSMutableDictionary *versions = [[NSMutableDictionary alloc] initWithContentsOfURL:versionPath];
    [versions removeObjectForKey:@"version"]; // remove the meta version of the index file.
    if (versions)
        return [versions allKeys];

<<<<<<< 38581355b6628cde6b1d30b9bbd7a6609075ddf9
    dispatch_once(&setupDefaultStrategies, ^{
        NSLog(@"Initializing default media strategies...");
        strategies = @[
                       [AmazonMusicStrategy new],
                       [AudibleStrategy new],
                       [AudioMackStrategy new],
                       [BandCampStrategy new],
                       [BBCRadioStrategy new],
                       [BeatguideStrategy new],
                       [BeatsMusicStrategy new],
                       [BlitzrStrategy new],
                       [BopFm new],
                       [BrainFmStrategy new],
                       [BugsMusicStrategy new],
                       [ChorusStrategy new],
                       [ComposedStrategy new],
                       [CourseraStrategy new],
                       [DailymotionStrategy new],
                       [DeezerStrategy new],
                       [DigitallyImportedStrategy new],
                       [EightTracksStrategy new],
                       [FocusAtWillStrategy new],
                       [GoogleMusicStrategy new],
                       [GrooveSharkStrategy new],
                       [HotNewHipHopStrategy new],
                       [HypeMachineStrategy new],
                       [iHeartRadioStrategy new],
                       [IndieShuffleStrategy new],
                       [JangoMediaStrategy new],
                       [KollektFmStrategy new],
                       [LastFmStrategy new],
                       [LeTournedisqueStrategy new],
                       [LogitechMediaServerStrategy new],
                       [MixCloudStrategy new],
                       [MusicForProgrammingStrategy new],
                       [MusicUnlimitedStrategy new],
                       [NetflixStrategy new],
                       [NoAdRadioStrategy new],
                       [NoonPacificStrategy new],
                       [NRKStrategy new],
                       [OdnoklassnikiStrategy new],
                       [OvercastStrategy new],
                       [PandoraStrategy new],
                       [PlexWebStrategy new],
                       [PocketCastsStrategy new],
                       [RadioSwissJazzStrategy new],
                       [RhapsodyStrategy new],
                       [SaavnStrategy new],
                       [ShufflerFmStrategy new],
                       [SlackerStrategy new],
                       [SomaFmStrategy new],
                       [SoundCloudStrategy new],
                       [SpotifyStrategy new],
                       [StitcherStrategy new],
                       [SubsonicStrategy new],
                       [SynologyStrategy new],
                       [TidalHiFiStrategy new],
                       [TuneInStrategy new],
                       [TwentyTwoTracksStrategy new],
                       [TwitchMediaStrategy new],
                       [UdemyStrategy new],
                       [VesselStrategy new],
                       [VimeoStrategy new],
                       [VkStrategy new],
                       [WatchaPlayStrategy new],
                       [WonderFmStrategy new],
                       [XboxMusicStrategy new],
                       [YandexMusicStrategy new],
                       [YandexRadioStrategy new],
                       [YouTubeStrategy new]
                    ];
    });
    return strategies;
=======
    return @[];
>>>>>>> Replaced MediaStrategies implementations with content plists containing relevant data.
}

@end
