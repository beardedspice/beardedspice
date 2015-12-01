//
//  AmazonMusicStrategy.m
//  BeardedSpice
//
//  Created by Brandon P Smith on 7/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AmazonMusicStrategy.h"

@implementation AmazonMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*amazon.*/gp/dmusic/cloudplayer/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *value = [tab executeJavascript:@"(function(){return window.amznMusic.widgets.player.isPlaying();}())"];

    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){return window.amznMusic.widgets.player.playHash('togglePlay')})()";
}

-(NSString *) pause
{
    return @"(function(){window.amznMusic.widgets.player.pause();})()";
}

-(NSString *) previous
{
    return @"(function(){return window.amznMusic.widgets.player.playHash('previous')})()";
}

-(NSString *) next
{
    return @"(function(){return window.amznMusic.widgets.player.playHash('next')})()";
}

-(NSString *) displayName
{
    return @"Amazon Music";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *status = [tab executeJavascript:@"window.amznMusic.widgets.player.getCurrent()"];
    NSDictionary *metadata = [status objectForKey:@"metadata"];

    Track *track = [[Track alloc] init];
    track.track = [metadata objectForKey:@"title"];
    track.album = [metadata objectForKey:@"albumName"];
    track.artist = [metadata objectForKey:@"artistName"];
    track.image = [self imageByUrlString:[metadata objectForKey:@"albumCoverImageSmall"]];

    return track;
}

@end
