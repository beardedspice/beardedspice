//
//  SubsonicStrategy.m
//  BeardedSpice
//
//  Created by Michael Alden on 4/8/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
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

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab title]];
}

-(NSString *) toggle
{
    return @"window.frames['playQueue'].jwplayer().play()";
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
    return @"window.frames['playQueue'].jwplayer().pause(true)";
}

-(NSString *) favorite
{
    return @"window.frames['playQueue'].onStar(window.frames['playQueue'].getCurrentSongIndex())";
}

-(NSString *) displayName
{
    return @"Subsonic";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    NSDictionary *metadata = [tab executeJavascript:@"window.frames['playQueue'].songs[window.frames['playQueue'].getCurrentSongIndex()]"];
    NSString *albumarturl = [tab executeJavascript:@"window.frames['playQueue'].songs[window.frames['playQueue'].getCurrentSongIndex()].albumUrl.replace('main','coverArt').concat('&size=128')"];
    Track *track = [[Track alloc] init];
    track.track = [metadata objectForKey:@"title"];
    track.album = [metadata objectForKey:@"album"];
    track.artist = [metadata objectForKey:@"artist"];
    track.image = [self imageByUrlString:albumarturl];
    return track;
}

@end
