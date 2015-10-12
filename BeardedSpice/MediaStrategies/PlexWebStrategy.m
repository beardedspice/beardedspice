//
//  PlexWebStrategy.m
//  BeardedSpice
//
//  Created by Ryan Sullivan on 8/20/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "PlexWebStrategy.h"

@implementation PlexWebStrategy


- (BOOL)accepts:(TabAdapter *)tab {
    
    NSNumber *result = [tab executeJavascript:@"(function(){return (window.PLEXWEB != undefined);})()"];
    return [result boolValue];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    NSNumber *value = [tab executeJavascript:@"(function(){var theButton = document.querySelector('.player.music .pause-btn'); if (theButton) return !(theButton.classList.contains('hidden')); else return (document.querySelector('.video-player.playing') != undefined);})()"];
    return [value boolValue];
}

- (NSString *)toggle {
    return @"(function (){ var thePlayer = document.querySelector('.player.music') ? '.player.music' : '.video-player'; document.querySelector(thePlayer+(document.querySelector(thePlayer+' .pause-btn').classList.contains('hidden') ? ' .play' : ' .pause')+'-btn').click();})()";
}

- (NSString *)previous {
    return @"(function (){ var thePlayer = document.querySelector('.player.music') ? '.player.music' : '.video-player'; document.querySelector(thePlayer+' .previous-btn').click()})()";
}

- (NSString *)next {
    return @"(function (){ var thePlayer = document.querySelector('.player.music') ? '.player.music' : '.video-player'; document.querySelector(thePlayer+' .next-btn').click()})()";
}

- (NSString *)pause {
    return @"(function (){ var thePlayer = document.querySelector('.player.music') ? '.player.music' : '.video-player'; document.querySelector(thePlayer+' .pause-btn').click()})()";
}

- (NSString *)displayName {
    return @"Plex Web";
}

- (Track *)trackInfo:(TabAdapter *)tab {

    NSDictionary *dict = [tab executeJavascript:@"(function (){ if(document.querySelector('.player.music')){  var mediaPoster = document.querySelector('.player.music .media-poster'); return {'imageUrl': mediaPoster.getAttribute('data-image-url'), 'track': mediaPoster.getAttribute('data-title'), 'album': mediaPoster.getAttribute('data-image-title'), 'artist': document.querySelector('.player.music  .grandparent-title').innerText, 'favorited': (document.querySelector('.player.music .rating-container .user-rating') != undefined)} } return {} } )()"];

    Track *track = [Track new];
    [track setValuesForKeysWithDictionary:dict];
    
    track.image = [self imageByUrlString:dict[@"imageUrl"]];
    
    return track;
}

@end
