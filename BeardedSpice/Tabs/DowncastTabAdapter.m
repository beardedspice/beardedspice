//
//  DowncastTabAdapter.m
//  BeardedSpice
//
//  Created by George Cox on 5/2/16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "DowncastTabAdapter.h"
#import "Downcast.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"

#define APPNAME_DOWNCAST         @"Downcast"
#define APPID_DOWNCAST           @"com.jamawkinaw.downcast.mac"

@implementation DowncastTabAdapter

+ (NSString *)displayName{
    
    return APPNAME_DOWNCAST;
}

+ (NSString *)bundleId{
    
    return APPID_DOWNCAST;
}

- (DowncastApplication *)downcast {
    return (DowncastApplication *)[self.application sbApplication];
}
- (NSString *)title {
    
    @autoreleasepool {
        DowncastNowPlayingInfo *npi = self.downcast.nowPlayingInfo;
        NSString *title;
        if (![NSString isNullOrEmpty:npi.episodeTitle])
            title = npi.episodeTitle;
        
        if (![NSString isNullOrEmpty:npi.publisher]) {
            if (title)
                title = [title stringByAppendingFormat:@" - %@", npi.publisher];
            else
                title = npi.publisher;
        }
        
        if ([NSString isNullOrEmpty:title]) {
            title = BSLocalizedString(@"No Track", @"DowncastTabAdapter");
        }
        
        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_DOWNCAST];
    }
}
- (NSString *)URL{
    
    return @"Downcast";
}

// We have only one window.
- (NSString *)key{
    
    return @"A:Downcast";
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{
    
    if (otherTab == nil || ![otherTab isKindOfClass:[DowncastTabAdapter class]]) return NO;
    
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (BOOL)toggle{
    DowncastApplication *downcast = self.downcast;
    if (downcast) {
        [downcast playpause];
        return YES;
    }
    return NO;
}
- (BOOL)pause{
    DowncastApplication *downcast = self.downcast;
    if (downcast) {
        [downcast pause];
        return YES;
    }
    return NO;
}
- (BOOL)next{
    DowncastApplication *downcast = self.downcast;
    if (downcast) {
        [downcast next];
        return YES;
    }
    return NO;
}
- (BOOL)previous{
    DowncastApplication *downcast = self.downcast;
    if (downcast) {
        [downcast previous];
        return YES;
    }
    return NO;
}

- (BSTrack *)trackInfo{
    DowncastApplication *downcast = self.downcast;
    if (downcast) {
        BSTrack *track = [BSTrack new];
        DowncastNowPlayingInfo *npi = downcast.nowPlayingInfo;
        track.track = npi.episodeTitle;
        track.album = npi.sourceTitle;
        track.artist = npi.publisher;
        NSData *artworkData = [npi.artworkData copy];
        if (artworkData != nil) {
            track.image = [[NSImage alloc] initWithData:artworkData];
        }
        return track;
    }
    
    return nil;
}

- (BOOL)isPlaying{
    DowncastApplication *downcast = self.downcast;
    if (downcast) {
        DowncastNowPlayingInfo *npi = downcast.nowPlayingInfo;
        return npi != nil && npi.isPlaying;
    }
    return NO;
}

@end
