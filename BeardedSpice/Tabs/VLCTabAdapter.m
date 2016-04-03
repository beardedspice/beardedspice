//
//  VLCTabAdapter.m
//  BeardedSpice
//
//  Created by Max Borghino on 2106-03-06
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "VLCTabAdapter.h"
#import "VLC.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "MediaStrategy.h"

#define APPNAME         @"VLC"
#define APPID           @"org.videolan.vlc"

@implementation VLCTabAdapter

+ (NSString *)displayName{

    return APPNAME;
}

+ (NSString *)bundleId{

    return APPID;
}

- (NSString *)title {

    @autoreleasepool {
        VLCApplication *vlc = (VLCApplication *)[self.application sbApplication];
        NSString *title;
        if (![NSString isNullOrEmpty:vlc.nameOfCurrentItem])
            title = vlc.nameOfCurrentItem;

        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", @"SpotifyTabAdapter");
        }

        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME];
    }
}
- (NSString *)URL{

    return @"VLC";
}

// We have only one window.
- (NSString *)key{

    return @"A:VLC";
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[VLCTabAdapter class]]) return NO;

    return YES;
}

// try to find the document which will respond to controls
// NOTE: this feels brittle, it seems there should be a better way
- (VLCDocument*) activeDocument {
    VLCDocument *doc = NULL;
    VLCApplication *vlc = (VLCApplication *)[self.application sbApplication];
    if (vlc) {
        NSEnumerator *e = [[vlc windows] objectEnumerator];
        id o;
        while ((o = [e nextObject]) && doc == NULL) {
            NSLog(@"VLC window %@: %lu: %@", o, [o index], [o name]);
            if ([[o name] isEqualToString: [vlc nameOfCurrentItem]]) {
                doc = [[[vlc windows] objectAtIndex: [o index]] document];
            }
        }
    }
    return doc;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{
    VLCDocument *doc = [self activeDocument];
    if (doc) {
        [doc play];
    }
}

- (void)pause{
    VLCApplication *vlc = (VLCApplication *)[self.application sbApplication];
    if (vlc && [vlc playing]) {
        VLCDocument *doc = [self activeDocument];
        if (doc) {
            [doc play];
        }
    }
}

- (void)next{
    VLCDocument *doc = [self activeDocument];
    if (doc) {
        [doc next];
    }
}

- (void)previous{
    VLCDocument *doc = [self activeDocument];
    if (doc) {
        [doc previous];
    }
}

- (Track *)trackInfo{
    VLCApplication *vlc = (VLCApplication *)[self.application sbApplication];
    if (vlc) {
        Track *track = [Track new];

        track.track = [vlc nameOfCurrentItem];
        track.artist = APPNAME;

        return track;
    }

    return nil;
}

- (BOOL)isPlaying{

    VLCApplication *vlc = (VLCApplication *)[self.application sbApplication];
    if (vlc) {
        return (BOOL)[vlc playing];
    }

    return NO;
}

@end
