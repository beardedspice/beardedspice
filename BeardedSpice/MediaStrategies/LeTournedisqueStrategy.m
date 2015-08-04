//
//  LeTournedisqueStrategy.m
//  BeardedSpice
//
//  Created by Jonas Friedmann on 18.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "LeTournedisqueStrategy.h"

@implementation LeTournedisqueStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*letournedisque.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *value = [tab
                       executeJavascript:@"(function(){return (document.querySelectorAll('.playing')[0]) ? true : false})();"];

    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('div.play')[0].click()})();";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('div.prev')[0].click()})();";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('div.next')[0].click()})();";
}

-(NSString *) pause
{
    return @"(function(){return document.querySelectorAll('div.play')[0].click()})();";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *song = [tab executeJavascript:@"(function(){return {artist:$('.info-text .artiste .inside_call').text(), track:$.trim($('.info-text .name').text())}})()"];

    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    track.artist = [song objectForKey:@"artist"];

    return track;
}

-(NSString *) displayName
{
    return @"LeTournedisque";
}

@end
