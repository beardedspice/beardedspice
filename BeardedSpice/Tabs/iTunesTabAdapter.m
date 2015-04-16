//
//  iTunesTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "iTunesTabAdapter.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "MediaStrategy.h"

@implementation iTunesTabAdapter

+(instancetype)iTunesTabAdapterWithApplication:(runningSBApplication *)application{
    
    iTunesTabAdapter *tab = [iTunesTabAdapter new];
    
    tab.application = application;
    return tab;
}

- (NSString *)title{

    @autoreleasepool {
        
        iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
        iTunesTrack *currentTrack = [[iTunes currentTrack] get];
        
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
            title = NSLocalizedString(@"No Track", @"iTunesTabAdapter");
        
        return [NSString stringWithFormat:@"%@ (%@)", title, iTunes.name];
    }
}

- (NSString *)URL{
    
    return @"iTunes";
}

// We have only one window.
- (NSString *)key{
    
    return @"A:ITUNES";
}

- (instancetype)copyStateFrom:(TabAdapter *)tab{
    
    if ([tab isKindOfClass:[self class]]) {
        iTunesTabAdapter *theTab = (iTunesTabAdapter *)tab;
        
        _wasActivated = theTab->_wasActivated;
    }
    
    return self;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[iTunesTabAdapter class]]) return NO;

    return YES;
}

- (void)activateTab{
    
    @autoreleasepool {
        
        if (![(iTunesApplication *)self.application.sbApplication frontmost]) {
            
            [self.application activate];
            _wasActivated = YES;
        }
        else
            _wasActivated = NO;
    }
}

- (void)toggleTab{
    
    if ([(iTunesApplication *)self.application.sbApplication frontmost]){
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
    
    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes playpause];
    }
}
- (void)pause{
    
    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes pause];
    }

}
- (void)next{
    
    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes nextTrack];
    }

}
- (void)previous{
    
    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        [iTunes previousTrack];
    }

}

- (void)favorite{
    
    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        iTunesTrack *track = [[iTunes currentTrack] get];
        if (track.rating)
            track.rating = 0;
        else
            track.rating = 100;
    }
    
}

- (Track *)trackInfo{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
        
        iTunesTrack *iTrack = [[iTunes currentTrack] get];
        Track *track = [Track new];
        
        track.track = iTrack.name;
        track.album = iTrack.album;
        track.artist = iTrack.artist;
        
        NSArray *artworks = [[iTrack artworks] get];
        iTunesArtwork *art = [[artworks firstObject] get];
        track.image = art.data;
        
        track.favorited = @(iTrack.rating);
        
        return track;
    }
    
    return nil;
}

- (BOOL)isPlaying{

    iTunesApplication *iTunes = (iTunesApplication *)[self.application sbApplication];
    if (iTunes) {
     
        switch (iTunes.playerState) {
                
            case iTunesEPlSPaused:
            case iTunesEPlSStopped:
                
                return NO;
                
            default:
                
                return YES;
        }
    }
    
    return NO;
}

@end
