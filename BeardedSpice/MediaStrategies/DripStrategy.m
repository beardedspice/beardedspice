//
//  DripStrategy.m
//  BeardedSpice
//
//  Created by Colin Drake on 8/21/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "DripStrategy.h"

@implementation DripStrategy

- (id)init
{
    self = [super init];
    
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*drip.com*'"];
    }
    
    return self;
}

- (BOOL)accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSString *info = [tab executeJavascript:@"document.querySelector('.player-trackname a').text"];
    NSArray *components = [info componentsSeparatedByString:@"—"];
    
    track.artist = [[components firstObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    track.track = [[components lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return track;
}

- (NSString *)toggle
{
    return @"(function(){var playing = document.querySelector('#player-controls .controls-play').classList.contains('ng-hide'); document.querySelector('#player-controls .controls-' + (playing ? 'pause' : 'play')).click()})()";
}

- (NSString *)previous
{
    return @"(function(){document.querySelector('#player-controls .controls-prev').click()})()";
}

- (NSString *)next
{
    return @"(function(){document.querySelector('#player-controls .controls-next').click()})()";
}

- (NSString *)pause
{
    return @"(function(){document.querySelector('#player-controls .controls-pause').click()})()";
}

- (NSString *)displayName
{
    return @"Drip";
}

@end
