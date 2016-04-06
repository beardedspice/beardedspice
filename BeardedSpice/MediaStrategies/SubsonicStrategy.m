//
//  SubsonicStrategy.m
//  BeardedSpice
//
//  Created by Michael Alden on 6/16/2015.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SubsonicStrategy.h"

@implementation SubsonicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*Subsonic*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab title]];
}

- (BOOL)isPlaying:(TabAdapter *)tab
{
    NSString *playerState;
    NSString *isNewPlayer = [tab executeJavascript:@"typeof window.frames['playQueue'].localPlayer"];
    
    if([isNewPlayer isEqualToString:@"object"]) {
        playerState = [tab executeJavascript:@"window.frames['playQueue'].localPlayer.paused ? 'PAUSED' : 'PLAYING'"];
    }
    else {
        playerState = [tab executeJavascript:@"window.frames['playQueue'].jwplayer().getState()"];
    }
    return [playerState isEqualToString:@"PLAYING"];

}

-(NSString *) toggle
{
    return @"(function(){ (typeof window.frames['playQueue'].localPlayer) === 'object' ? (window.frames['playQueue'].localPlayer.paused ? window.frames['playQueue'].onStart() : window.frames['playQueue'].onStop()) : window.frames['playQueue'].jwplayer().play() })()";
}

-(NSString *) previous
{
    return @"window.frames['playQueue'].onPrevious()";
}

-(NSString *) next
{
    return @"window.frames['playQueue'].onNext()";
}

-(NSString *) pause
{
    return @"(function(){ (typeof window.frames['playQueue'].onStop) === 'function' ? window.frames['playQueue'].onStop() : window.frames['playQueue'].jwplayer().pause(true) })()";}

-(NSString *) favorite
{
    return @"window.frames['playQueue'].onStar(window.frames['playQueue'].getCurrentSongIndex())";
}

-(NSString *) displayName
{
    return @"Subsonic";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ var ret = window.frames['playQueue'].songs[window.frames['playQueue'].getCurrentSongIndex()]; ret['albumArtUrl'] = window.frames['playQueue'].songs[window.frames['playQueue'].getCurrentSongIndex()].albumUrl.replace('main','coverArt').concat('&size=128'); return ret;})()"];
    Track *track = [[Track alloc] init];
    track.track = [metadata objectForKey:@"title"];
    track.album = [metadata objectForKey:@"album"];
    track.artist = [metadata objectForKey:@"artist"];
    track.image = [self imageByUrlString:metadata[@"albumArtUrl"]];
    track.favorited = [metadata objectForKey:@"starred"];
    
    return track;
}

@end