//
//  ComposedStrategy.m
//  BeardedSpice
//
//  Created by Daniel Roseman on 23/06/2015.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "ComposedStrategy.h"

@implementation ComposedStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*play.composed.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL) isPlaying:(TabAdapter *)tab {
    
    NSNumber *value = [tab
        executeJavascript:@"(function(){return document.querySelectorAll('.player-buttons__pause').length != 0})()"];
    
    return [value boolValue];
}
-(NSString *) toggle
{
    return @"(function(){document.querySelectorAll('.player-buttons button')[1].click()})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelectorAll('.player-buttons__previous')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelectorAll('.player-buttons__next')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){document.querySelectorAll('.player-buttons__pause')[0].click()})()";
}

-(NSString *) displayName
{
    return @"Composed";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab
        executeJavascript:@"(function(){return {"
                          @"title: document.querySelectorAll('.player-controls__track')[0].title,"
                          @"composer: document.querySelectorAll('.player-controls__composer')[0].textContent,"
                          @"albumArt: document.querySelectorAll('.player-controls__packshot img')[0].src}})();"
                            ];
    Track *track = [Track new];
    
    track.track = info[@"title"];
    track.artist = info[@"composer"];
    track.image = [self imageByUrlString:info[@"albumArt"]];
    
    return track;
}
@end
