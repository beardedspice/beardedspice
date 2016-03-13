//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by 박종운 on 2016. 1. 8..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "naverMusicStrategy.h"

@implementation naverMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*player.music.naver.com/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return document.getElementsByClassName('play_controller')[0].getElementsByTagName('button')[1].title != ‘재생’; })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ document.getElementsByClassName('play_controller')[0].getElementsByTagName('button')[1].click(); })()";
}

-(NSString *) previous
{
    return @"(function(){ document.getElementsByClassName('play_controller')[0].getElementsByTagName('button')[0].click(); })()";
}

-(NSString *) next
{
    return @"(function(){ document.getElementsByClassName('play_controller')[0].getElementsByTagName('button')[2].click(); })()";
}

-(NSString *) pause
{
    return @"(function(){ document.getElementsByClassName('play_controller')[0].getElementsByTagName('button')[1].click(); })()";
}

-(NSString *) displayName
{
    return @"naverMusic";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image: document.getElementsByClassName('album_img')[0].getElementsByTagName('img')[0].src,"
                              @"  track: document.getElementsByClassName('song')[0].getElementsByTagName('span')[0].innerText,"
                              @"  artist: document.getElementsByClassName('artist')[0].getElementsByTagName('span')[0].innerText,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

@end
