//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by 박종운 on 2016. 1. 8..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "MnetStrategy.h"

@implementation MnetStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*player.mnet.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return document.getElementById('btnPlay').style.display == 'none'; })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ document.getElementById('btnPause').click(); })()";
}

-(NSString *) previous
{
    return @"(function(){ document.getElementById('btnPrev').click(); })()";
}

-(NSString *) next
{
    return @"(function(){ document.getElementById('btnNext').click(); })()";
}

-(NSString *) pause
{
    return @"(function(){ document.getElementById('btnPause').click(); })()";
}

-(NSString *) displayName
{
    return @"Mnet";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image: document.getElementsByClassName('albumImg')[0].getElementsByTagName('img')[0].src,"
                              @"  track: document.getElementsByClassName('albumTit')[0].getElementsByTagName('a')[0].innerText,"
                              @"  artist: document.getElementsByClassName('albumTit')[0].getElementsByTagName('a')[1].innerText,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

@end
