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

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"!function(){var e=document.querySelector('.jp-type-single'),l=document.querySelector('a.jp-play'),t=document.querySelector('a.jp-pause'),c=document.querySelector('.track_play'),u='none'===getComputedStyle(e,null).display,n='none'===getComputedStyle(l,null).display;u?c.click():n?t.click():l.click()}();";
}

-(NSString *) previous
{
    return @""; // Not available
}

-(NSString *) next
{
     return @"(function(){document.querySelector('a.jp-next').click()})()";
}

-(NSString *) pause
{
     return @"(function(){document.querySelector('a.jp-pause').click()})()";
}

-(NSString *) displayName
{
    return @"WonderFM";
}

-(Track *) trackInfo:(id<Tab>)tab
{
  Track *track = [[Track alloc] init];
  [track setTrack:[tab executeJavascript:@"document.querySelector('.current_url').text"]];
  [track setArtist:[tab executeJavascript:@"document.querySelector('#current_track > a').text"]];

  return track;
}

-(NSString *) favorite
{
  return @"document.querySelector('.track_active .track_fav').click()";
}

@end
