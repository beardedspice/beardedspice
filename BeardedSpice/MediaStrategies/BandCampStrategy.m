//
//  BandCampStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "BandCampStrategy.h"

@implementation BandCampStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*bandcamp.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){gplaylist.playpause()})()";
}

-(NSString *) previous
{
    return @"(function(){gplaylist.prev_track()})()";
}

-(NSString *) next
{
    return @"(function(){gplaylist.next_track()})()";
}

-(NSString *) pause
{
    return @"(function(){gplaylist.pause()})()";
}

-(NSString *) displayName
{
    return @"BandCamp";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *song = [tab executeJavascript:@"(function(){return {artist:EmbedData.artist, album:EmbedData.album_title, track:gplaylist.get_track_info().title}})()"];

    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    track.album = [song objectForKey:@"album"];
    track.artist = [song objectForKey:@"artist"];

    return track;
}

@end
