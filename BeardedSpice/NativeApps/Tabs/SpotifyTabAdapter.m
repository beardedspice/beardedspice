//
//  SpotifyTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SpotifyTabAdapter.h"
#import "runningSBApplication.h"
#import "BSTrack.h"
#import "NSString+Utils.h"
#import "BSMediaStrategy.h"
#import "NSURL+Utils.h"

#define APPID_SPOTIFY           @"com.spotify.client"
#define APPNAME_SPOTIFY         @"Spotify"

@implementation SpotifyTabAdapter

static NSString *_lastTrackId;
static NSImage *_lastTrackImage;

+ (NSString *)displayName{
    static NSString *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        name = [super displayName];
    });
    return name ?: APPNAME_SPOTIFY;
}

+ (NSString *)bundleId{

    return APPID_SPOTIFY;
}

- (NSString *)title{

    @autoreleasepool {

        SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
        SpotifyTrack *currentTrack = [Spotify currentTrack];

        NSString *title;
        if (currentTrack) {

            if (![NSString isNullOrEmpty:currentTrack.name])
                title = currentTrack.name;

            if (![NSString isNullOrEmpty:currentTrack.artist]) {

                if (title) title = [title stringByAppendingFormat:@" - %@", currentTrack.artist];
                else
                    title = currentTrack.artist;
            }
        }

        if ([NSString isNullOrEmpty:title]) {
            title = BSLocalizedString(@"no-track-title", @"No tack title for tabs menu and default notification ");
        }

        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_SPOTIFY];
    }
}

- (NSString *)URL{

    return APPID_SPOTIFY;
}

// We have only one window.
- (NSString *)key{

    return @"A:" APPID_SPOTIFY;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[SpotifyTabAdapter class]]) return NO;

    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (BOOL)toggle{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        [Spotify playpause];
    }
    return YES;
}
- (BOOL)pause{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        [Spotify pause];
    }
    return YES;
}
- (BOOL)next{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        SpotifyTrack *track = Spotify.currentTrack;
        NSString *uri = track.spotifyUrl;
        if ([uri hasPrefix:@"spotify:episode:"]) {
            double position = Spotify.playerPosition + 15;
            Spotify.playerPosition = position > track.duration ? track.duration : position;
        }
        else {
            [Spotify nextTrack];
        }
    }
    return YES;
}
- (BOOL)previous{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        SpotifyTrack *track = Spotify.currentTrack;
        NSString *uri = track.spotifyUrl;
        if ([uri hasPrefix:@"spotify:episode:"]) {
            double position = Spotify.playerPosition - 15;
            Spotify.playerPosition = position < 0 ? 0.0 : position;
        }
        else {
            [Spotify previousTrack];
        }
    }
    return YES;
}

- (BSTrack *)trackInfo{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {

        SpotifyTrack *iTrack = [Spotify currentTrack];
        BSTrack *track = [BSTrack new];

        track.track = iTrack.name;
        track.album = iTrack.album;
        NSString *uri = iTrack.spotifyUrl;
        if ([uri hasPrefix:@"spotify:episode:"]) {
            track.artist = [self timeFormSeconds:Spotify.playerPosition];
        }
        else {
            track.artist = iTrack.artist;
        }
        [track setImageWithUrlString:iTrack.artworkUrl];
        
        return track;
    }

    return nil;
}

- (NSString *)timeFormSeconds:(double)seconds {
    NSUInteger hours = (seconds / 3600);
    NSUInteger mins = (NSUInteger)(seconds / 60) % 60;
    NSUInteger secs = (NSUInteger)(seconds) % 60;
    return hours ? [NSString stringWithFormat:@"%lu:%.2lu:%.2lu", hours, mins, secs] :
    [NSString stringWithFormat:@"%.2lu:%.2lu", mins, secs];
}

- (BOOL)isPlaying{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {

        switch (Spotify.playerState) {

            case SpotifyEPlSPaused:
            case SpotifyEPlSStopped:

                return NO;

            default:

                return YES;
        }
    }

    return NO;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods

@end
