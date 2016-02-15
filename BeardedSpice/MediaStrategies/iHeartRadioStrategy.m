//
//  iHeartRadioStrategy.m
//  BeardedSpice
//
//  Created by Coder-256 on 2/7/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "iHeartRadioStrategy.h"

@implementation iHeartRadioStrategy

- (id)init {
    self = [super init];
    
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*iheart.com*'"];
    }
    
    return self;
    
}
-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *value = [tab executeJavascript:@"(document.querySelectorAll('[aria-label=\"Stop\"]').length > 0)"];
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){if (document.querySelectorAll('[aria-label=\"Stop\"]').length > 0) {document.querySelector('[aria-label=\"Stop\"]').click();} else {var plays = document.querySelectorAll('[aria-label=\"Play Station\"]'); plays[plays.length-1].click();}})()";
}


-(NSString *) pause
{
    return @"(function(){document.querySelector('[aria-label=\"Stop\"]').click();})()";
}

- (NSString *)next {
    return @"(function(){document.querySelector('[aria-label=\"Skip\"]').click();})()";
}

/*
- (NSString *)previous {
    return @"";
}*/

- (Track *)trackInfo:(TabAdapter *)tab {
    
    NSDictionary *info = [tab
                          executeJavascript:@"(function(){\
                          return {\
                          'track': document.querySelector(\".player-song\").textContent,\
                          'album': document.querySelector(\".player-artist\").textContent,\
                          /*'artist': null,*/\
                          'albumArt': document.querySelector(\".player-art > img\").src.split(\"?\")[0]\
                          };\
                          })()"];
    
    Track *track = [Track new];
    
    track.track  = info[@"track"];
    
    //track.artist = [info[@"artist"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    track.album  = [info[@"album"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    track.image  = [self imageByUrlString:info[@"albumArt"]];
    
    return track;
}

-(NSString *) displayName
{
    return @"iHeart Radio";
}

@end
