//
//  BSTVTabAdapter.m
//  Beardie
//
//  Created by Roman Sokolov on 13.11.2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSTVTabAdapter.h"
#import "runningSBApplication.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"
#import "NSString+Utils.h"

#define APPID       @"com.apple.TV"
#define APPNAME     @"TV"
#define DELTA       30 // seconds

@implementation BSTVTabAdapter

+ (id)tabAdapterWithApplication:(runningSBApplication *)application {

    BSTVTabAdapter *tab = [super tabAdapterWithApplication:application];
    if (tab) {
    }

    return tab;
}

+ (NSString *)displayName {
    static NSString *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        name = [super displayName];
    });
    return name ?: APPNAME;
}

+ (NSString *)bundleId{
    return APPID;
}

- (NSString *)title{

    @autoreleasepool {

        TVApplication *tv = (TVApplication *)[self.application sbApplication];
        TVTrack *currentTrack = [tv currentTrack];

        NSString *title;
        if (currentTrack) {

            if (currentTrack.name.length){
                title = currentTrack.name;
            }
        }

        if ([NSString isNullOrEmpty:title]) {
            title = BSLocalizedString(@"no-track-title", @"No tack title for tabs menu and default notification ");
        }

        return [NSString stringWithFormat:@"%@ (%@)", title, BSTVTabAdapter.displayName];
    }
}

- (NSString *)URL{

    return APPID;
}

// We have only one window.
- (NSString *)key{

    return @"A:" APPID;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[BSTVTabAdapter class]]) return NO;

    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (BOOL)toggle{

    TVApplication *tv = (TVApplication *)[self.application sbApplication];
    if (tv) {
        [tv playpause];
    }
    return YES;
}
- (BOOL)pause{

    TVApplication *tv = (TVApplication *)[self.application sbApplication];
    if (tv) {
        [tv pause];
    }
    return YES;
}
- (BOOL)next{

    TVApplication *tv = (TVApplication *)[self.application sbApplication];
    if (tv) {
        TVTrack *track = [tv currentTrack];
        double duration = track.duration;
        double nextPos = tv.playerPosition + DELTA;
        if (nextPos < duration || duration == 0) {
            tv.playerPosition = nextPos;
        }
        else {
            [tv nextTrack];
        }
    }
    return YES;
}
- (BOOL)previous{
    
    TVApplication *tv = (TVApplication *)[self.application sbApplication];
    if (tv) {
        double nextPos = tv.playerPosition - DELTA;
        if (nextPos > 0) {
            tv.playerPosition = nextPos;
        }
        else {
            [tv previousTrack];
        }
    }
    return YES;
    
}

- (BOOL)favorite{

    return NO;
}

- (BSTrack *)trackInfo{
    
//    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
//    if (music) {
//
//        MusicTrack *track = [music currentTrack];
//        if (track) {
//            BSTrack *trackInfo = [BSTrack new];
//
//            trackInfo.track = track.name;
//            trackInfo.album = track.album;
//            trackInfo.artist = track.artist;
//
//            NSArray *artworks = [[track artworks] get];
//            MusicArtwork *art = [artworks firstObject];
//            trackInfo.image = art.data;
//
//            @try {
//                trackInfo.favorited = @(track.loved);
//            }
//            @catch (NSException *exception) {
//                DDLogError(@"Error when calling [Music loved]: %@", exception);
//                ERROR_TRACE;
//            }
//
//            return trackInfo;
//        }
//    }

    return nil;
}

- (BOOL)isPlaying{

    TVApplication *tv = (TVApplication *)[self.application sbApplication];
    if (tv) {

        switch (tv.playerState) {

            case TVEPlSPaused:
            case TVEPlSStopped:

                return NO;

            default:

                return YES;
        }
    }

    return NO;
}

- (BOOL)showNotifications{
    return YES;
}

@end
