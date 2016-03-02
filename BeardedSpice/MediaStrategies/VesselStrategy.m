//
//  VesselStrategy.m
//  BeardedSpice
//
//  Created by Coder-256 on 2/7/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "VesselStrategy.h"

@implementation VesselStrategy

- (id)init {
    self = [super init];
    
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*vessel.com/videos/*'"];
    }
    
    return self;
    
}
-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *value = [tab executeJavascript:@"!(function(){return document.querySelector('video.video-show').paused}())"];
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){v=document.querySelector('video.video-show');if (v.paused) {v.play();}else{v.pause();};}())";
}


-(NSString *) pause
{
    return @"(function(){document.querySelector('video.video-show').pause()}())";
}

-(NSString *) play
{
    return @"(function(){document.querySelector('video.video-show').play()}())";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    
    NSDictionary *info = [tab
                          executeJavascript:@"(function(){\
                          return {\
                          'track': document.title.substr(6),\
                          /*'album': document.querySelector(\".player-artist\").textContent,*/\
                          /*'artist': null,*/\
                          'albumArt': document.querySelector('img[style=\"width:34px;height:34px;border-bottom-left-radius:4px;border-top-left-radius:4px;\"]').src.replace(/\\?w=.*/, '')\
                          };\
                          })()"];
    
    Track *track = [Track new];
    
    track.track  = info[@"track"];
    
    //track.artist = [info[@"artist"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //track.album  = [info[@"album"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    track.image  = [self imageByUrlString:info[@"albumArt"]];
    
    return track;
}

-(NSString *) displayName
{
    return @"Vessel";
}

@end
