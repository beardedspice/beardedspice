//
//  GrooveSharkStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GrooveSharkStrategy.h"

@implementation GrooveSharkStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*grooveshark.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.Grooveshark.togglePlayPause()})()";
}

-(NSString *) previous
{
    return @"(function(){return window.Grooveshark.previous()})()";
}

-(NSString *) next
{
    return @"(function(){return window.Grooveshark.next()})()";
}

-(NSString *) pause
{
    return @"(function(){return window.Grooveshark.pause()})()";
}

-(NSString *) favorite
{
    return @"(function(){return window.Grooveshark.favoriteCurrentSong()})()";
}

-(NSString *) displayName
{
    return @"Grooveshark";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *status = [tab executeJavascript:@"window.Grooveshark.getCurrentSongStatus()"];
    NSDictionary *song = [status objectForKey:@"song"];

    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"songName"];
    track.album = [song objectForKey:@"albumName"];
    track.artist = [song objectForKey:@"artistName"];

    return track;
}

@end
