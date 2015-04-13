//
//  HypeMachineStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "HypeMachineStrategy.h"

@implementation HypeMachineStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*hypem.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.togglePlay()})()";
}

-(NSString *) previous
{
    return @"(function(){return window.prevTrack()})()";
}

-(NSString *) next
{
    return @"(function(){return window.nextTrack()})()";
}

-(NSString *) pause
{
    return @"(function(){return window.currentPlayerObj[0].pause()})()";
}

-(NSString *) favorite
{
    return @"(function (){return window.toggleFavoriteItem()})()";
}

-(NSString *) displayName
{
    return @"HypeMachine";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *song = [tab executeJavascript:@"(function(){return {artist:now_playing[0].text, track:now_playing[2].text}})()"];

    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    track.artist = [song objectForKey:@"artist"];

    return track;
}

@end
