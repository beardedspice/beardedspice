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

@implementation SpotifyTabAdapter

+(instancetype)SpotifyTabAdapterWithApplication:(runningSBApplication *)application{
    
    SpotifyTabAdapter *tab = [SpotifyTabAdapter new];
    
    tab.application = application;
    return tab;
}

- (NSString *)title{

    @autoreleasepool {
        
        SpotifyApplication *Spotify = (SpotifyApplication *)[self.application sbApplication];
        SpotifyTrack *currentTrack = [[Spotify currentTrack] get];
        
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

- (instancetype)copyStateFrom:(TabAdapter *)tab{
    
    if ([tab isKindOfClass:[self class]]) {
        SpotifyTabAdapter *theTab = (SpotifyTabAdapter *)tab;
        
        _wasActivated = theTab->_wasActivated;
    }
    
    return self;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[SpotifyTabAdapter class]]) return NO;

    return YES;
}

- (void)activateTab{
    
    @autoreleasepool {
        
        if (![(SpotifyApplication *)self.application.sbApplication frontmost]) {
            
            [self.application activate];
            _wasActivated = YES;
        }
        else
            _wasActivated = NO;
    }
}

- (void)toggleTab{
    
    if ([(SpotifyApplication *)self.application.sbApplication frontmost]){
        if (_wasActivated) {
            
            [self.application hide];
            _wasActivated = NO;
        }
    }
    else
        [self activateTab];
}


- (BOOL)frontmost{
    
    return self.application.frontmost;
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
        
        SpotifyTrack *iTrack = [[Spotify currentTrack] get];
        Track *track = [Track new];
        
        track.track = iTrack.name;
        track.album = iTrack.album;
        track.artist = iTrack.artist;
        
        NSArray *artworks = [[iTrack artworks] get];
        SpotifyArtwork *art = [[artworks firstObject] get];
        track.image = art.data;
        
        track.favorited = @(iTrack.rating);
        
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

@end
