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

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('.player-controls__play').click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelector('.skip').click()})()";
}

-(NSString *) displayName
{
    return @"YandexRadio";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    Track *track = [[Track alloc] init];

    [track setTrack:[tab executeJavascript:@"document.querySelector('.slider__items div:nth-child(3) .track .track__info .track__title a').title"]];
    [track setArtist:[tab executeJavascript:@"document.querySelector('.slider__items div:nth-child(3) .track .track__info .track__artists').title"]];
    return track;
}

@end
