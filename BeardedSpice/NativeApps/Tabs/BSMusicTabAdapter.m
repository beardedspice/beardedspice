//
//  BSMusicTabAdapter.m
//  Beardie
//
//  Created by Roman Sokolov on 11.11.2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSMusicTabAdapter.h"
#import "runningSBApplication.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"
#import "NSString+Utils.h"

#define ERROR_TRACE                         DDLogError(@"Error trace - %s[%p]: %@", __FILE__, self, NSStringFromSelector(_cmd));

#define APPID                  @"com.apple.Music"
#define APPNAME                @"Music"

@implementation BSMusicTabAdapter {
    BOOL _musicNeedDisplayNotification;
}

+ (id)tabAdapterWithApplication:(runningSBApplication *)application {

    BSMusicTabAdapter *tab = [super tabAdapterWithApplication:application];
    if (tab) {
        tab->_musicNeedDisplayNotification = YES;
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

        MusicApplication *music = (MusicApplication *)[self.application sbApplication];
        MusicTrack *currentTrack = [music currentTrack];

        NSString *title;
        if (currentTrack) {

            if (currentTrack.name.length){
                title = currentTrack.name;
            }
            
            if (currentTrack.artist.length) {

                if (title) title = [title stringByAppendingFormat:@" - %@", currentTrack.artist];
                else
                    title = currentTrack.artist;
            }
        }

        if ([NSString isNullOrEmpty:title]) {
            title = BSLocalizedString(@"no-track-title", @"No tack title for tabs menu and default notification ");
        }

        return [NSString stringWithFormat:@"%@ (%@)", title, BSMusicTabAdapter.displayName];
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

    if (otherTab == nil || ![otherTab isKindOfClass:[BSMusicTabAdapter class]]) return NO;

    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (BOOL)toggle{

    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
    if (music) {
        [music playpause];
    }
    _musicNeedDisplayNotification = YES;
    return YES;
}
- (BOOL)pause{

    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
    if (music) {
        [music pause];
    }
    _musicNeedDisplayNotification = YES;
    return YES;
}
- (BOOL)next{

    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
    if (music) {
        [music nextTrack];
    }
    _musicNeedDisplayNotification = NO;
    return YES;
}
- (BOOL)previous{

    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
    if (music) {
        [music previousTrack];
    }
    _musicNeedDisplayNotification = NO;
    return YES;
}

- (BOOL)favorite{

    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
    if (music) {
        MusicTrack *track = [music currentTrack];
        @try {
            if ([track loved])
                track.loved = NO;
            else
                track.loved = YES;
        }
        @catch (NSException *exception) {

            DDLogError(@"Error when calling [Music loved]: %@", exception);
            ERROR_TRACE;
        }
    }
    return YES;
}

- (BSTrack *)trackInfo{

    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
    if (music) {

        MusicTrack *track = [music currentTrack];
        if (track) {
            BSTrack *trackInfo = [BSTrack new];

            trackInfo.track = track.name;
            trackInfo.album = track.album;
            trackInfo.artist = track.artist;

            NSArray *artworks = [[track artworks] get];
            MusicArtwork *art = [artworks firstObject];
            trackInfo.image = art.data;

            @try {
                trackInfo.favorited = @(track.loved);
            }
            @catch (NSException *exception) {
                DDLogError(@"Error when calling [Music loved]: %@", exception);
                ERROR_TRACE;
            }

            return trackInfo;
        }
    }

    return nil;
}

- (BOOL)isPlaying{

    MusicApplication *music = (MusicApplication *)[self.application sbApplication];
    if (music) {

        switch (music.playerState) {

            case MusicEPlSPaused:
            case MusicEPlSStopped:

                return NO;

            default:

                return YES;
        }
    }

    return NO;
}

- (BOOL)showNotifications{
    return _musicNeedDisplayNotification;
}

@end
