//
//  VOXTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 20.06.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "VOXTabAdapter.h"
#import "VOX.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"

#define APPNAME_VOX         @"VOX"
#define APPID_VOX           @"com.coppertino.Vox"

@implementation VOXTabAdapter

+ (NSString *)displayName{

    return APPNAME_VOX;
}

+ (NSString *)bundleId{

    return APPID_VOX;
}

- (NSString *)title {

    @autoreleasepool {

        VOXApplication *vox =
            (VOXApplication *)[self.application sbApplication];

        NSString *title;
        if (![NSString isNullOrEmpty:vox.track])
            title = vox.track;

        if (![NSString isNullOrEmpty:vox.artist]) {

            if (title)
                title = [title stringByAppendingFormat:@" - %@", vox.artist];
            else
                title = vox.artist;
        }

        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", @"SpotifyTabAdapter");
        }

        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_VOX];
    }
}
- (NSString *)URL{

    return @"VOX";
}

// We have only one window.
- (NSString *)key{

    return @"A:VOX";
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[VOXTabAdapter class]]) return NO;

    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{

    VOXApplication *vox = (VOXApplication *)[self.application sbApplication];
    if (vox) {
        [vox playpause];
    }
}
- (void)pause{

    VOXApplication *vox = (VOXApplication *)[self.application sbApplication];
    if (vox) {
        [vox pause];
    }

}
- (void)next{

    VOXApplication *vox = (VOXApplication *)[self.application sbApplication];
    if (vox) {
        [vox next];
    }

}
- (void)previous{

    VOXApplication *vox = (VOXApplication *)[self.application sbApplication];
    if (vox) {
        [vox previous];
    }

}

- (BSTrack *)trackInfo{

    VOXApplication *vox = (VOXApplication *)[self.application sbApplication];
    if (vox) {

        BSTrack *track = [BSTrack new];

        track.track = vox.track;
        track.album = vox.album;
        track.artist = vox.artist;
        track.image = [vox artworkImage];

        NSURL *url = [NSURL URLWithString:vox.trackUrl];

        if (url) {
            NSLog(@"URL: %@", url);
        }

        return track;
    }

    return nil;
}

- (BOOL)isPlaying{

    VOXApplication *vox = (VOXApplication *)[self.application sbApplication];
    if (vox) {
        return (BOOL)vox.playerState;
    }

    return NO;
}

@end
