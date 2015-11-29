//
//  SongzaStrategy.m
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/18/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SongzaStrategy.h"

@implementation SongzaStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*songza.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *value = [tab executeJavascript:@"(function(){return document.querySelector('.player-wrapper').classList.contains('player-state-play');}())"];

    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('.miniplayer-control-play-pause').click()})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelector('.miniplayer-control-skip').click()})()";
}

-(NSString *) pause
{
    return @"(function(){if (document.querySelector('.player-wrapper').classList.contains('player-state-play')) document.querySelector('.miniplayer-control-play-pause').click()})()";
}

- (NSString *)favorite
{
    // favorites the playlist (not the track)
    return @"(function(){document.querySelector('.miniplayer-info-playlist-favorite-status').click()})()";
}

-(NSString *) displayName
{
    return @"Songza";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){var track=document.querySelector('.miniplayer-info-track-title > a').getAttribute('title'), artist=document.querySelector('.miniplayer-info-artist-name > a').getAttribute('title'), albumArt=document.querySelector('.miniplayer-album-art').getAttribute('src'); return {'track': track, 'artist': artist, 'albumArt': albumArt}})()"];

    Track *track = [[Track alloc] init];

    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.image = [self imageByUrlString:info[@"albumArt"]];
    // no persistent track favorite state available

    return track;
}
@end
