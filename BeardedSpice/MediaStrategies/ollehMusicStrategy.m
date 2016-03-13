//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by 박종운 on 2016. 1. 8..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "ollehMusicStrategy.h"

@implementation ollehMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*ollehmusic.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return document.getElementById('playImg').title != ‘재생'; })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ playClick(); })()";
}

-(NSString *) previous
{
    return @"(function(){ preBtnClick(); })()";
}

-(NSString *) next
{
    return @"(function(){ nextBtnClick(); })()";
}

-(NSString *) pause
{
    return @"(function(){ playClick(); })()";
}

-(NSString *) displayName
{
    return @"ollehMusic";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image: document.getElementsByClassName('album_view')[0].getElementsByTagName('img')[0].src,"
                              @"  track: document.getElementsByClassName('song')[0].innerText,"
                              @"  artist: document.getElementsByClassName('artist')[0].innerText,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

@end
