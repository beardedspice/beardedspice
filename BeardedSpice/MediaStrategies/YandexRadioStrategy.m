//
//  YandexMusicStrategy.m
//  BeardedSpice
//
//  Created by Leonid Ponomarev 15.06.15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YandexRadioStrategy.h"

@implementation YandexRadioStrategy

-(id) init {
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*radio.yandex.*'"];
    }
    return self;
}

-(NSString *) displayName {
    return @"Yandex.Radio";
}

-(BOOL) accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL) isPlaying:(TabAdapter *)tab {
    NSNumber *result = [tab executeJavascript:@"externalAPI.isPlaying()"];
    
    return [result boolValue];
}

-(Track *) trackInfo:(TabAdapter *)tab {
    Track *track = [[Track alloc] init];
    
    NSDictionary *info = [tab executeJavascript:@"externalAPI.getCurrentTrack()"];
    
    track.track = info[@"title"];
    track.artist = info[@"artists"][0][@"title"];
    track.album = info[@"album"][@"title"];
    track.favorited = info[@"liked"];

    NSString *urlCover = info[@"cover"];
    urlCover = [urlCover stringByReplacingOccurrencesOfString:@"\%\%" withString:@"600x600"];
    track.image = [self imageByUrlString:urlCover];
    
    return track;
}

-(NSString *) toggle {
    return @"externalAPI.togglePause()";
}

-(NSString *) next {
    return @"externalAPI.next()";
}

-(NSString *) pause {
    return @"(function(){if(externalAPI.isPlaying())externalAPI.togglePause();})()";
}

-(NSString *) favorite {
    return @"externalAPI.toggleLike()";
}

@end
