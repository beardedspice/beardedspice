//
//  EightTracksStrategy.m
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/15/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "EightTracksStrategy.h"

@implementation EightTracksStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*8tracks.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){window.mixPlayer?window.mixPlayer.toggle():document.querySelector('#play_overlay').click()})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){window.mixPlayer.next()})()";
}

-(NSString *) pause
{
    return @"(function(){window.mixPlayer.pause()})()";
}

- (NSString *)favorite
{
    // NOTE: This favorites the current track, not the current mix
    return @"(function(){document.querySelector('#now_playing a.fav').click()})()";
}

-(NSString *) displayName
{
    return @"8tracks";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    NSDictionary *song = [tab executeJavascript:@"(function(){return {artist:mixPlayer.track.get('performer'),album:mixPlayer.track.get('release_name'),track:mixPlayer.track.get('name')}})()"];
    
    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    track.album = [song objectForKey:@"album"];
    track.artist = [song objectForKey:@"artist"];
    
    return track;
}

@end
