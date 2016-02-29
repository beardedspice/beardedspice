//
//  RadiumTabAdapter.m
//  BeardedSpice
//
//  Created by Jacob on 2/19/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "RadiumTabAdapter.h"
#import "Radium.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "MediaStrategy.h"

#define APPNAME_RADIUM         @"Radium"
#define APPID_RADIUM           @"com.catpigstudios.Radium3"

@implementation RadiumTabAdapter

+ (NSString *)displayName{
    
    return APPNAME_RADIUM;
}

+ (NSString *)bundleId{
    
    return APPID_RADIUM;
}

- (NSString *)title {
    
    @autoreleasepool {
        
        RadiumApplication *radium =
        (RadiumApplication *)[self.application sbApplication];
        
        NSString *title;
        if (![NSString isNullOrEmpty:radium.trackName])
            title = radium.trackName;
        
        if (![NSString isNullOrEmpty:radium.stationName]) {
            
            if (title)
                title = [title stringByAppendingFormat:@" - %@", radium.stationName];
            else
                title = radium.stationName;
        }
        
        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", nil);
        }
        
        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_RADIUM];
    }
}
- (NSString *)URL{
    
    return @"Radium";
}

    // We have only one window.
- (NSString *)key{
    
    return @"A:Radium";
}

    // We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{
    
    if (otherTab == nil || ![otherTab isKindOfClass:[RadiumTabAdapter class]]) return NO;
    
    return YES;
}

    //////////////////////////////////////////////////////////////
#pragma mark Player control methods
    //////////////////////////////////////////////////////////////

- (void)toggle{
    
    RadiumApplication *radium =
    (RadiumApplication *)[self.application sbApplication];
    if (radium) {
        [radium playpause];
    }
}
- (void)pause{
    
    RadiumApplication *radium =
    (RadiumApplication *)[self.application sbApplication];
    if (radium) {
        [radium pause];
    }
    
}


- (Track *)trackInfo{
    
    RadiumApplication *radium =
    (RadiumApplication *)[self.application sbApplication];
    if (radium) {
        
        Track *track = [Track new];
        
        if (![NSString isNullOrEmpty:radium.trackName]) {
            track.track = radium.trackName;
        }
        
        if (![NSString isNullOrEmpty:radium.stationName]) {
            track.artist = radium.stationName;
        }
        
        artwork = [radium trackArtwork];
        
        if (artwork != nil) {
            track.image = artwork;
        }
        
        return track;
    }
    
    return nil;
}

- (BOOL)isPlaying{
    
    RadiumApplication *radium =
    (RadiumApplication *)[self.application sbApplication];
    if (radium) {
        return (BOOL)radium.playing;
    }
    
    return NO;
}

@end
