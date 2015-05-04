//
//  SpotifyTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SpotifyTabAdapter.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "MediaStrategy.h"
#import "NSURL+Utils.h"

#define APPID_SPOTIFY           @"com.spotify.client"
#define APPNAME_SPOTIFY         @"Spotify"
#define URL_INFO_FORMAT         @"https://api.spotify.com/v1/tracks/%@"
#define GET_INFO_TIMEOUT        1.0
#define IMAGE_OPTIMAL_WIDTH     128

@implementation SpotifyTabAdapter

static NSString *_lastTrackId;
static NSImage *_lastTrackImage;

+(instancetype)SpotifyTabAdapterWithApplication:(runningSBApplication *)application{
    
    SpotifyTabAdapter *tab = [SpotifyTabAdapter new];
    
    tab.application = application;
    return tab;
}

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
        else
            title = NSLocalizedString(@"No Track", @"SpotifyTabAdapter");
        
        return [NSString stringWithFormat:@"%@ (%@)", title, Spotify.name];
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

- (id)executeJavascript:(NSString *)javascript{

    return nil;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{
    
    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        [Spotify playpause];
    }
}
- (void)pause{
    
    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        [Spotify pause];
    }

}
- (void)next{
    
    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        [Spotify nextTrack];
    }

}
- (void)previous{
    
    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        [Spotify previousTrack];
    }

}

- (void)favorite{
    
}

- (Track *)trackInfo{

    SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
    if (Spotify) {
        
        SpotifyTrack *iTrack = [Spotify currentTrack];
        Track *track = [Track new];
        
        track.track = iTrack.name;
        track.album = iTrack.album;
        track.artist = iTrack.artist;
        track.image = [self imageForId:iTrack.id];
        
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
/////////////////////////////////////////////////////////////////////////
- (NSImage *)imageForId:(NSString *)trackId {

    if ([_lastTrackId isEqualToString:trackId]) {
        return _lastTrackImage;
    }

    _lastTrackId = trackId;
    _lastTrackImage = nil;

    NSString *realId = [[trackId componentsSeparatedByString:@":"] lastObject];
    if (realId) {
        NSURL *infoUrl = [NSURL
            URLWithString:[NSString stringWithFormat:URL_INFO_FORMAT, realId]];
        if (infoUrl) {
            NSData *infoData = [infoUrl getDataWithTimeout:GET_INFO_TIMEOUT];
            if (infoData) {
                id dict = [NSJSONSerialization JSONObjectWithData:infoData
                                                          options:0
                                                            error:NULL];
                if (dict) {
                    if ([dict isKindOfClass:[NSDictionary class]]) {
                        NSUInteger width = 0, delta = NSUIntegerMax,
                                   newDelta = NSUIntegerMax;

                        NSString *imageUrl;
                        for (NSDictionary *imageInfo in
                                 dict[@"album"][@"images"]) {
                            // using NSUinteger for width gives us strange method to approximate
                            width = [imageInfo[@"width"] unsignedIntegerValue];
                            newDelta = (width - IMAGE_OPTIMAL_WIDTH);
                            if (width && newDelta < delta) {
                                delta = newDelta;
                                imageUrl = imageInfo[@"url"];
                            }
                        }

                        if (imageUrl) {

                            NSURL *url = [NSURL URLWithString:imageUrl];
                            if (url) {
                                if (!url.scheme) {
                                    url = [NSURL
                                        URLWithString:
                                            [NSString
                                                stringWithFormat:@"http:%@",
                                                                 imageUrl]];
                                }
                                _lastTrackImage =
                                    [[NSImage alloc] initWithContentsOfURL:url];
                            }
                        }
                    }
                }
            }
        }
    }

    return _lastTrackImage;
}

@end
