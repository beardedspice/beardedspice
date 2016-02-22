//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by 박종운 on 2016. 1. 8..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "genieStrategy.h"

@implementation genieStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*genie.co.kr/player*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return document.getElementsByClassName('pause')[0] == undefined; })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ document.getElementById('PlayBtnArea').click(); })()";
}

-(NSString *) previous
{
    return @"(function(){ document.getElementsByClassName('control-2')[0].getElementsByClassName('prev')[0].click(); })()";
}

-(NSString *) next
{
    return @"(function(){ document.getElementsByClassName('control-2')[0].getElementsByClassName('next')[0].click(); })()";
}

-(NSString *) pause
{
    return @"(function(){ document.getElementById('PlayBtnArea').click(); })()";
}

-(NSString *) displayName
{
    return @"genie";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image: document.getElementById('AlbumImgArea').getElementsByTagName('img')[0].src,"
                              @"  track: document.getElementById('SongTitleArea').innerText,"
                              @"  artist: document.getElementById('ArtistNameArea').innerText,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

@end
