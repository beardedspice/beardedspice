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
#define URL_INFO_FORMAT         @"https://api.spotify.com/v1/tracks/%@"
#define GET_INFO_TIMEOUT        1.0
#define IMAGE_OPTIMAL_WIDTH     128


@implementation SpotifyTabAdapter

static NSString *_lastTrackId;
static NSImage *_lastTrackImage;

+ (NSString *)displayName{

    return APPNAME_SPOTIFY;
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
            title = BSLocalizedString(@"No Track", @"SpotifyTabAdapter");
        }

        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_SPOTIFY];
    }
}

- (NSString *)URL{

    return @"Spotify";
}

// We have only one window.
- (NSString *)key{

    return @"A:SPOTIFY";
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
        [Spotify nextTrack];
    }
    return YES;
}
- (BOOL)previous{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        [Spotify previousTrack];
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
        track.artist = iTrack.artist;
        [track setImageWithUrlString:iTrack.artworkUrl];

        return track;
    }

    return nil;
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
