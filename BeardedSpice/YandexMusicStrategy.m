//
//  YandexMusicStrategy.m
//  BeardedSpice
//
//  Created by Vladimir Burdukov on 3/14/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YandexMusicStrategy.h"

@implementation YandexMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*music.yandex.*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('div.b-jambox__play, .player-controls__btn_play').click()})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelector('div.b-jambox__prev, .player-controls__btn_prev').click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelector('div.b-jambox__next, .player-controls__btn_next').click()})()";
}

-(NSString *) pause
{
    return @"(function(){\
        var e=document.querySelector('.player-controls__btn_play');\
        if(e!=null){\
            if(e.classList.contains('player-controls__btn_pause')){e.click()}\
        }else{\
            var e=document.querySelector('div.b-jambox__play');\
            if(e.classList.contains('b-jambox__playing')){e.click()}\
        }\
    })()";
}

-(NSString *) displayName
{
    return @"YandexMusic";
}

- (NSString *)favorite{
    
    return @"(function(){$('.player-controls .like.player-controls__btn').click();})()";
}

- (Track *)trackInfo:(id<Tab>)tab{

    NSDictionary *info = [tab executeJavascript:@"(function(){return $.extend(JSON.parse($('body').attr('data-unity-state')), ({'favorited': ($('.player-controls .like.like_on.player-controls__btn').length)}))})()"];
    
    Track *track = [Track new];
    
    track.track = info[@"title"];
    track.artist = info[@"artist"];
    track.image = [self imageByUrlString:info[@"albumArt"]];
    track.favorited = info[@"favorited"];
    
    return track;
}

@end
