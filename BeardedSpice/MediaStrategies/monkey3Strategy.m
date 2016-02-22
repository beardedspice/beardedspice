//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by 박종운 on 2016. 1. 8..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "monkey3Strategy.h"

@implementation monkey3Strategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*monkey3.co.kr*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return document.getElementsByClassName('resume')[0] == undefined; })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ document.getElementById('ctrl1').click(); })()";
}

-(NSString *) previous
{
    return @"(function(){ document.getElementById('ctrl_prev').click(); })()";
}

-(NSString *) next
{
    return @"(function(){ document.getElementById('ctrl_next').click(); })()";
}

-(NSString *) pause
{
    return @"(function(){ document.getElementById('ctrl1').click(); })()";
}

-(NSString *) displayName
{
    return @"monkey3";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image: document.getElementsByClassName('img')[0].getElementsByTagName('img')[0].src,"
                              @"  track: document.getElementById('crnt_title').value,"
                              @"  artist: document.getElementById('crnt_artist').value,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

@end
