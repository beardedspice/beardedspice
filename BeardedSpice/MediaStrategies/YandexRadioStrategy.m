//
//  YandexMusicStrategy.m
//  BeardedSpice
//
//  Created by Leonid Ponomarev 15.06.15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YandexRadioStrategy.h"

@implementation YandexRadioStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*radio.yandex.ru*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *value =
            [tab executeJavascript:@"(function(){return JSON.parse($('body').attr('class').length!=0)})()"];
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('.player-controls__play').click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelector('.skip').click()})()";
}

- (NSString *)pause {
    return @"(function(){\
        if($('body').attr('class').length!=0){\
            document.querySelector('.player-controls__play').click()\
        }\
    })()";
}

-(NSString *) favorite {
    return @"(function(){document.querySelector('.like_action_like').click()})()";
}

-(NSString *) displayName
{
    return @"YandexRadio";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];

    [track setTrack:[tab executeJavascript:@"document.querySelector('.slider__items div:nth-child(3) .track .track__info .track__title a').title"]];
    [track setArtist:[tab executeJavascript:@"document.querySelector('.slider__items div:nth-child(3) .track .track__info .track__artists').title"]];
    track.image = [self imageByUrlString:[tab executeJavascript:@"document.querySelector('.slider__items div:nth-child(3) .track img.track__cover').src"]];

    NSNumber *value =
            [tab executeJavascript:@"(function(){return JSON.parse($('.like_action_like').attr('class').includes('button_checked'))})()"];
    track.favorited = value;
    return track;
}

@end
