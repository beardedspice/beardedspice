//
//  SoundCloudStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SoundCloudStrategy.h"

@implementation SoundCloudStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*soundcloud.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('.playControl')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('.skipControl__previous')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('.skipControl__next')[0].click()})()";
}

-(NSString *) favorite
{
    return @"(function (){return document.querySelectorAll('div.playControls button.playbackSoundBadge__like')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){var play = document.querySelectorAll('.playControl')[0];if(play.classList.contains('sc-button-pause')){play.click();}})()";
}

-(NSString *) displayName
{
    return @"SoundCloud";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *song = [tab executeJavascript:@"(function(){return { \
                          'track':  document.querySelector('a.playbackSoundBadge__title.sc-truncate').title, \
                          'album':  document.querySelector('a.playbackSoundBadge__title.sc-truncate').href.split('/')[3], \
                          'artist': '', \
                          'image':  document.querySelector('span.sc-artwork.sc-artwork-placeholder-0.image__full').style['background-image'].slice(4, -1)} \
                          })()"];
    
    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    track.album = [song objectForKey:@"album"];
    track.artist = [song objectForKey:@"artist"];
    track.image = [self imageByUrlString:song[@"image"]];
    
    return track;
}

@end
