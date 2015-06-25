//
//  EmbyStrategy.m
//  BeardedSpice
//
//  Created by Andrew Scott on 6/25/15.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "EmbyStrategy.h"

@implementation EmbyStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*localhost:8096*' OR SELF LIKE[c] '*127.0.0.1:8096*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){return MediaPlayer.currentMediaRenderer.paused()})()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){if(MediaPlayer.currentMediaRenderer.paused()){MediaPlayer.unpause()}else{MediaPlayer.pause()}})()";
}

-(NSString *) previous
{
    return @"(function(){return MediaPlayer.previousTrack()})()";
}

-(NSString *) next
{
    return @"(function(){return MediaPlayer.nextTrack()})()";
}

-(NSString *) pause
{
    return @"(function(){return MediaPlayer.pause()})()";
}

-(NSString *) displayName
{
    return @"Emby";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ var ret = MediaPlayer.currentItem; ret['imageUrl'] = document.querySelector('.nowPlayingImage > img:first-of-type').src; return ret;})()"];
    
    Track *track = [[Track alloc] init];
    track.track = [metadata objectForKey:@"Name"];
    track.album = [metadata objectForKey:@"Album"];
    track.artist = [metadata objectForKey:@"AlbumArtist"];
    track.image = [self imageByUrlString:[metadata objectForKey:@"imageUrl"]];

    return track;
}

@end