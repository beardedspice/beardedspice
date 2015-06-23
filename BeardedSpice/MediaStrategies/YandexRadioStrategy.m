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
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*radio.yandex.*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *value =
            [tab executeJavascript:@"(function(){return Mu.Flow.flow.player.isPlaying();})()"];
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){Mu.Flow.togglePause();})()";
}

-(NSString *) next
{
    return @"(function(){var nextTreckInfo = Mu.Flow.flow.getNextTrack(); Mu.Flow.flow.next(\"nextpressed\"); return nextTreckInfo})()";
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

- (Track *)trackInfo:(TabAdapter *)tab {
    Track *track = [[Track alloc] init];

    // This "!(Mu.Flow.player.isPaused() || Mu.Flow.player.isPaused())"
    // determine that flow is changed in current time.
    NSDictionary *info =
        [tab executeJavascript:@"(function(){ var result; if "
             @"(!(Mu.Flow.player.isPaused() || "
             @"Mu.Flow.player.isPlaying())) result = "
             @"Mu.Flow.flow.getNextTrack(); else{ result = "
             @"Mu.Flow.flow.getTrack(); result['liked'] = "
             @"$('.like_action_like').hasClass('button_checked');} return "
             @"result; })()"];

    NSString *version = info[@"version"];

    track.track =
        (version ? [NSString stringWithFormat:@"%@ %@", info[@"title"], version]
                 : info[@"title"]);

    NSArray *list = info[@"artists"];
    if (list) {
        track.artist =
            [[list valueForKey:@"name"] componentsJoinedByString:@" "];
    }
    list = info[@"albums"];
    if (list) {
        track.album = list[0][@"title"];
        NSString *urlString = list[0][@"coverUri"];
        urlString = [NSString
            stringWithFormat:@"http://%@",
                             [urlString stringByReplacingOccurrencesOfString:
                                            @"\%\%" withString:@"600x600"]];
        track.image = [self imageByUrlString:urlString];
    }
    track.favorited = info[@"liked"];

    return track;
}

@end
