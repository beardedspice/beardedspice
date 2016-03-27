//
//  DeezerTabAdapter.m
//  BeardedSpice
//
//  Created by Stefan Schwetschke on 27.03.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "DeezerTabAdapter.h"
#import "Deezer.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "MediaStrategy.h"

#define APPNAME_DEEZER         @"Deezer"
#define APPID_DEEZER           @"com.deezer.Deezer"

@implementation DeezerTabAdapter

+ (NSString *)displayName{
    
    return APPNAME_DEEZER;
}

+ (NSString *)bundleId{
    
    return APPID_DEEZER;
}

- (NSString *)title {
    
    @autoreleasepool {
        
        DeezerApplication *deezer =
        (DeezerApplication *)[self.application sbApplication];
        
        NSString *title;
        DeezerTrack *track=deezer.loadedTrack;
        if (track!=nil){
            
            if (![NSString isNullOrEmpty:track.title])
                title = track.title;
            
            if (![NSString isNullOrEmpty:track.artist]) {
                
                if (title)
                    title = [title stringByAppendingFormat:@" - %@", track.artist];
                else
                    title = track.artist;
            }
        }
        
        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", @"SpotifyTabAdapter");
        }
        
        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_DEEZER];
    }
}
- (NSString *)URL{
    
    return @"VOX";
}

// We have only one window.
- (NSString *)key{
    
    return @"A:Deezer";
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{
    
    if (otherTab == nil || ![otherTab isKindOfClass:[DeezerTabAdapter class]]) return NO;
    
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{
    
    DeezerApplication *deezer = (DeezerApplication *)[self.application sbApplication];
    if (deezer) {
        [deezer playpause];
    }
}
- (void)pause{
    
    DeezerApplication *deezer = (DeezerApplication *)[self.application sbApplication];
    if (deezer) {
        [deezer pause];
    }
    
}
- (void)next{
    
    DeezerApplication *deezer = (DeezerApplication *)[self.application sbApplication];
    if (deezer) {
        [deezer nextTrack];
    }
    
}
- (void)previous{
    
    DeezerApplication *deezer = (DeezerApplication *)[self.application sbApplication];
    if (deezer) {
        [deezer previousTrack];
    }
    
}

- (Track *)trackInfo{
    
    DeezerApplication *deezer = (DeezerApplication *)[self.application sbApplication];
    if (deezer) {
        
        Track *track = [Track new];
        DeezerTrack *deezerTrack=deezer.loadedTrack;
        if (deezerTrack!=nil){
            track.track = deezerTrack.title;
            track.album = deezerTrack.album;
            track.artist = deezerTrack.artist;
            NSData *imageData = deezerTrack.cover;
            if (imageData != nil){
                track.image=[[NSImage alloc] initWithData: imageData];
            }
        }
        
        return track;
    }
    
    return nil;
}

- (BOOL)isPlaying{
    
    DeezerApplication *deezer = (DeezerApplication *)[self.application sbApplication];
    if (deezer) {
        return deezer.playerState == DeezerEPlSPlaying;
    }
    
    return NO;
}

@end
