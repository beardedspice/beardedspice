//
//  BlitzrStrategy.m
//  BeardedSpice
//
//  Created by Pascal Fouque on 23/07/2015.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BlitzrStrategy.h"

@implementation BlitzrStrategy

- (id)init {
    self = [super init];
    if (self) {
        predicate =
        [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*blitzr.com*'"];
    }
    return self;
}

- (BOOL)accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    
    NSNumber *value =
    [tab executeJavascript:@"(function(){ \
        return document.querySelector('#blitzr_playpause span.fa').className.indexOf('fa-play') == -1 \
     })()"];
    
    return [value boolValue];
}

- (NSString *)toggle {
    return @"(function(){document.querySelector('#blitzr_playpause').click()})()";
}

- (NSString *)previous {
    return @"(function(){document.querySelector('#blitzr_prev').click()})()";
}

- (NSString *)next {
    return @"(function(){document.querySelector('#blitzr_next').click()})()";
}

- (NSString *)pause {
    return @"if (document.querySelector('#blitzr_playpause span.fa').className.indexOf('fa-play') == -1) { \
        document.querySelector('#blitzr_playpause').click() \
    }";
}

- (NSString *)displayName {
    return @"Blitzr";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    
    NSDictionary *info =
    [tab executeJavascript:@"(function(){ return { \
        'track': document.querySelector('#playerTitle strong').innerHTML, \
        'album': document.querySelector('#playerInfo .media-left a').title, \
        'artist': document.querySelectorAll('#playerArtists')[0].querySelector('a').innerHTML, \
        'albumArt': document.querySelector('#playerInfo .media-left a img').style['background-image'].slice(4, -1), \
     }; })()"];
    
    Track *track = [Track new];
    
    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.album = info[@"album"];
    track.image = [self imageByUrlString:info[@"albumArt"]];
    
    return track;
}

@end
