//
//  RadioSwissJazzStrategy.m
//  BeardedSpice
//
//  Created by Eleni Lixourioti on 05/01/2016.
//  Copyright (c) 2016 BeardedSpice. All rights reserved.
//

#import "RadioSwissJazzStrategy.h"

@implementation RadioSwissJazzStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*radioswissjazz.ch*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *result = [tab executeJavascript:@"(function(){ return document.querySelectorAll('div.jp-state-playing').length; })()"];
    return [result boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ document.querySelector('.play-ctr a.jp-pause').click(); })()";
}

-(NSString *) pause
{
    return @"(function() { if (document.querySelectorAll('div.jp-state-playing').length) { document.querySelector('.play-ctr a.jp-pause').click(); }})()";
}

-(NSString *) displayName
{
    return @"Radio Swiss Jazz";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];

    NSString *baseImageUrl = @"http://www.radioswissjazz.ch";
    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image:  document.querySelector('#live img.cover,.current-airplay img.cover').getAttribute('src'),"
                              @"  album:  document.querySelector('#live img.cover,.current-airplay img.cover').getAttribute('title'),"
                              @"  track:  document.querySelector('#live .title,.current-airplay .title').innerText,"
                              @"  artist: document.querySelector('#live .artist,.current-airplay .artist').innerText,"
                              @"}})()"];

    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[baseImageUrl stringByAppendingString:[metadata valueForKey:@"image"]]];
    track.artist = [metadata valueForKey:@"artist"];

    NSString *coverTitle = [metadata valueForKey:@"album"];
    NSRange albumRange = [coverTitle rangeOfString:@": "];

    if (albumRange.location != NSNotFound) {
        albumRange.location += 2;
        track.album = [coverTitle substringWithRange:NSMakeRange(albumRange.location,
                                                                 coverTitle.length - albumRange.location)];
    }

    return track;
}

@end
