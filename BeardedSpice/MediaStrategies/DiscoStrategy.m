//
//  DiscoStrategy.m
//  BeardedSpice
//
//  Created by Colin Drake on 8/19/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "DiscoStrategy.h"

@implementation DiscoStrategy

- (id)init
{
    self = [super init];
    
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*disco.io*'"];
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
    
    track.artist = [tab executeJavascript:@"$('#current-track-artist').text()"];
    track.track = [tab executeJavascript:@"$('#current-track-title').text()"];
    
    return track;
}

- (NSString *)toggle
{
    return @"(function(){$('#play-button').click()})()";
}

- (NSString *)previous
{
    return @"(function(){$('#previous-button').click()})()";
}

- (NSString *)next
{
    return @"(function(){$('#next-button').click()})()";
}

- (NSString *)pause
{
    return @"(function(){$('#play-button').click()})()";
}

- (NSString *)displayName
{
    return @"disco.io";
}

@end
