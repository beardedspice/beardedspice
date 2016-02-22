//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by 박종운 on 2016. 1. 8..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "MelonStrategy.h"

@implementation MelonStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*melon.com/webplayer*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return document.getElementById('WebPlayer_PlayBtn').title != '재생'; })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ document.getElementById('WebPlayer_PlayBtn').click(); })()";
}

-(NSString *) previous
{
    return @"(function(){ document.getElementsByClassName('btn_prev')[0].click(); })()";
}

-(NSString *) next
{
    return @"(function(){ document.getElementsByClassName('btn_next')[0].click(); })()";
}

-(NSString *) pause
{
    return @"(function(){ document.getElementsByClassName('btn_pause')[0].click(); })()";
}

-(NSString *) displayName
{
    return @"Melon";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image:  document.getElementById('albumImg').getElementsByTagName('img')[0].src,"
                              @"  track: document.getElementsByClassName('playing')[0].getElementsByClassName('item_song')[0].innerText,"
                              @"  artist: document.getElementsByClassName('playing')[0].getElementsByClassName('item_artist')[0].innerText,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

@end
