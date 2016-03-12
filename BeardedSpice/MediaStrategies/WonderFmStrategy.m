//
//  WonderFmStrategy.m
//  BeardedSpice
//
//  Created by Kyle Conarro on 2/3/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "WonderFmStrategy.h"

@implementation WonderFmStrategy


-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*wonder.fm*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{
    NSNumber *result = [tab executeJavascript:@"(function(){return document.querySelector('.track--active:not(.track--paused)')})();"];
    return [result boolValue];
}

-(NSString *) toggle
{
    return @"!function(){document.querySelector('.show--activeTrack .player-play').click()}();";
}

-(NSString *) previous
{
    return @""; // Not available
}

-(NSString *) next
{
     return @"(function(){document.querySelector('.show--activeTrack .player-skip').click()})();";
}

-(NSString *) pause
{
     return @"(function(){document.querySelector('.show--activeTrack .player-pause').click()})();";
}

-(NSString *) displayName
{
    return @"Wonder FM";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
  Track *track = [[Track alloc] init];
  [track setTrack:[tab executeJavascript:@"document.querySelector('.currentTrack .song').text"]];
  [track setArtist:[tab executeJavascript:@"document.querySelector('.currentTrack .artist').text"]];

  return track;
}

-(NSString *) favorite
{
  return @"document.querySelector('.track--active .track-fav').click();";
}

@end
