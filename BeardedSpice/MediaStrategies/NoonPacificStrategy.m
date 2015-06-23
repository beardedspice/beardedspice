//
//  NoonPacific.m
//  BeardedSpice
//
//  Created by Tomas on 07/05/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NoonPacificStrategy.h"

@implementation NoonPacificStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*noonpacific.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *value =
        [tab executeJavascript:@"(function()"
                               @"{return document.querySelector('.fa-pause')"
                               @"?true:false;})()"];

    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('.fa-fw')[1].click()})()";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelector('.fa-backward').click()})()";
}

-(NSString *) next
{
    return @"(function(){return document.querySelector('.fa-forward').click()})()";
}

-(NSString *) pause
{
    return @"(function(){return document.querySelector('.fa-pause').click()})()";}

-(NSString *) displayName
{
    return @"NoonPacific";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    NSDictionary *info =
        [tab executeJavascript:@"(function(){"
             @"var track=document.querySelectorAll('.track-info div p');"
             @"var imgSrc=document.querySelector('.mixtape-container "
             @"img.mixtape').getAttribute('src');"
             @"var album=document.querySelector('.mixtape-container "
             @"div.mixtape-label h3').innerText;"
             @"return {'title':track[0].firstChild.nodeValue,"
             @"'artist':track[1].firstChild.nodeValue, 'album':album, "
             @"'art':imgSrc};})()"];

    Track *track = [[Track alloc] init];

    track.track = info[@"title"];
    track.artist = info[@"artist"];
    track.album = info[@"album"];
    track.image = [self imageByUrlString:info[@"art"]];

    return track;
}

@end
