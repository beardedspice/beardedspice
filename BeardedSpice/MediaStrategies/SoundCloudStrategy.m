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

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *val = [tab
        executeJavascript:@"(function(){var play = "
                          @"document.querySelector('.playControl'); return "
                          @"play.classList.contains('playing');})()"];
    return [val boolValue];
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
    return @"(function (){return document.querySelector('div.playControls button.playbackSoundBadge__like').click()})()";
}

-(NSString *) pause
{
    return @"(function(){var play = document.querySelector('.playControl');if(play.classList.contains('playing')){play.click();}})()";
}

-(NSString *) displayName
{
    return @"SoundCloud";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    NSDictionary *song =
        [tab executeJavascript:@"(function(){return { 'track': document.querySelector('a.playbackSoundBadge__title.sc-truncate').title, 'album': document.querySelector('a.playbackSoundBadge__title.sc-truncate').href.split('/')[3], 'artist': '', 'image': document.querySelector('div.playControls span.sc-artwork').style['background-image'].slice(4, -1), 'favorited': document.querySelector('div.playControls button.playbackSoundBadge__like').classList.contains('sc-button-selected')} })()"];

    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    track.album = [song objectForKey:@"album"];
    track.artist = [song objectForKey:@"artist"];
    track.favorited = song[@"favorited"];
    track.image = [self imageByUrlString:song[@"image"]];

    return track;
}

@end
