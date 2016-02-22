//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by 박종운 on 2016. 1. 8..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "soribadaStrategy.h"

@implementation soribadaStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*soribada.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return document.getElementById('play').title != ‘재생’; })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ document.getElementById('play').click(); })()";
}

-(NSString *) previous
{
    return @"(function(){ document.getElementById('prev').click(); })()";
}

-(NSString *) next
{
    return @"(function(){ document.getElementById('next').click(); })()";
}

-(NSString *) pause
{
    return @"(function(){ document.getElementById('play').click(); })()";
}

-(NSString *) displayName
{
    return @"soribada";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image: document.getElementById('cover').getElementsByTagName('img')[0].src,"
                              @"  track: document.getElementsByClassName('pado_tit_wrap')[0].getElementsByTagName('strong')[0].innerText,"
                              @"  artist: document.getElementsByClassName('pado_tit_wrap')[0].getElementsByTagName('span')[1].innerText,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

@end
