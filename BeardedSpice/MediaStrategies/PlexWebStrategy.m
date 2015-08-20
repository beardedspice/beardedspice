//
//  PlexWebStrategy.m
//  BeardedSpice
//
//  Created by Ryan Sullivan on 8/20/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "PlexWebStrategy.h"

@implementation PlexWebStrategy

- (id)init {
    self = [super init];
    if (self) {
        predicate =
        [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*:32400/web*' OR SELF LIKE[c] '*app.plex.tv/web/app*'"];
    }
    return self;
}


- (BOOL)accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    NSNumber *value = [tab executeJavascript:@"document.querySelector('.player .pause-btn').classList.contains('hidden')"];
    return [value boolValue];
}

- (NSString *)toggle {
    return @"document.querySelector('.player .'+(document.querySelector('.player .pause-btn').classList.contains('hidden') ? 'play' : 'pause')+'-btn').click()";
}

- (NSString *)previous {
    return @"document.querySelector('.player .previous-btn').click()";
}

- (NSString *)next {
    return @"document.querySelector('.player .next-btn').click()";
}

- (NSString *)pause {
    return @"document.querySelector('.player .pause-btn').click()";
}

- (NSString *)displayName {
    return @"Plex Web";
}

//- (NSString *)favorite {
//}

//- (Track *)trackInfo:(TabAdapter *)tab {
//
//    NSString *infoArtist = [tab executeJavascript:@"return document.querySelector('.player .media-title .grandparent-title-container').innerText"];
//    NSString *infoTrack = [tab executeJavascript:@"return document.querySelector('.player .media-title .title-container').innerText"];
//
//    Track *track = [Track new];
//    track.artist = infoArtist;
//    track.track = infoTrack;
//
//    return track;
//}

@end
