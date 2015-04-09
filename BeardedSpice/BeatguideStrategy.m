//
//  BeatguideStrategy.m
//  BeardedSpice
//
//  Created by Colin White on 08/04/15.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "BeatguideStrategy.h"

@implementation BeatguideStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*beatguide.me*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('.play-icon')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('.fa-backward')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('.fa-forward')[0].click()})()";
}

-(NSString *) favorite
{
    return @"";
}

-(NSString *) pause
{
    return @"(function(){return document.querySelectorAll('.fa-pause')[0].click()})()";}

-(NSString *) displayName
{
    return @"Beatguide";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){return {'track': document.querySelectorAll('.track-title')[0].innerText, 'artist': document.querySelectorAll('.artist-name')[0].innerText, imageUrl: document.querySelectorAll('.track-artwork')[0].src}})()"];

    Track *track = [[Track alloc] init];

    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.image = [self imageByUrlString:info[@"imageUrl"]];

//    NSLog(@"\nNotification: %@ - %@, %@\n", track.artist, track.track, info[@"imageUrl"]);

    return track;
}

@end
