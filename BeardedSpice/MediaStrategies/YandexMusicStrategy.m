//
//  YandexMusicStrategy.m
//  BeardedSpice
//
//  Created by Vladimir Burdukov on 3/14/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YandexMusicStrategy.h"

@implementation YandexMusicStrategy

- (id)init {
    self = [super init];
    if (self) {
        predicate =
            [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*music.yandex.*'"];
    }
    return self;
}

- (BOOL)accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *value =
        [tab executeJavascript:@"(function(){return "
                               @"(document.querySelector('.player-controls__btn_play.player-controls__btn_pause') != null);}())"
         ];

    return [value boolValue];
}

- (NSString *)toggle {
    return @"(function(){document.querySelector('div.b-jambox__play, "
           @".player-controls__btn_play').click()})()";
}

- (NSString *)previous {
    return @"(function(){document.querySelector('div.b-jambox__prev, "
           @".player-controls__btn_prev').click()})()";
}

- (NSString *)next {
    return @"(function(){document.querySelector('div.b-jambox__next, "
           @".player-controls__btn_next').click()})()";
}

- (NSString *)pause {
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

- (NSString *)displayName {
    return @"YandexMusic";
}

- (NSString *)favorite {

    return @"(function(){$('.player-controls "
           @".like.player-controls__btn').click();})()";
}

- (Track *)trackInfo:(TabAdapter *)tab {

    NSDictionary *info = [tab
        executeJavascript:@"(function(){var track = $('.track.track_type_player').get(0); return {'track': $('.track__title', track)[0].innerText, 'artist': $('.track__artists', track)[0].innerText, 'favorited': $('.player-controls__track-controls .like.player-controls__btn').hasClass('like_on'), 'albumArt': $('.album-cover', track).attr('src')}})()"];

    Track *track = [Track new];

    [track setValuesForKeysWithDictionary:info];
    track.image = [self imageByUrlString:info[@"albumArt"]];

    return track;
}

@end
