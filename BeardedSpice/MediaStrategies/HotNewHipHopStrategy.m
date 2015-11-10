//
//  HotNewHipHopStrategy.m
//  BeardedSpice
//
//  Created by Ivan Doroshenko on 11/7/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "HotNewHipHopStrategy.h"

@implementation HotNewHipHopStrategy

- (instancetype)init {
    self = [super init];
    
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*hotnewhiphop.com*'"];
    }
    
    return self;
    
}
-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *value = [tab executeJavascript:@"$(\"#jquery_jplayer_playlist\").data().jPlayer.status.paused;"];
    return ![value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){\
    if ($(\"#jquery_jplayer_playlist\").data().jPlayer.status.paused) { \
    $(\"#jquery_jplayer_playlist\").jPlayer(\"play\");\
    } else { \
    $(\"#jquery_jplayer_playlist\").jPlayer(\"pause\");\
    } \
    })()";
}


-(NSString *) pause
{
    return @"(function(){$(\"#jquery_jplayer_playlist\").jPlayer(\"pause\");})()";
}

- (NSString *)next {
    return @"(function(){$(\".jp-next\").click();})()";
}

- (NSString *)previous {
    return @"(function(){$(\".jp-previous\").click();})()";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    
    NSDictionary *info = [tab
                          executeJavascript:@"(function(){\
                          return {\
                          'track': $('.jp-playlist-current .mixtape-trackTitle .display')[0].innerText,\
                          'album': $('.mixtape-info-title')[0].innerText,\
                          'artist': $('.mixtape-info-artist')[0].innerText,\
                          'albumArt': $('.mixtape-cover-img img')[0].getAttribute('src')\
                          };\
                          })()"];
    
    Track *track = [Track new];
    
    track.track  = info[@"track"];
    
    track.artist = [info[@"artist"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    track.album  = [info[@"album"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    track.image  = [self imageByUrlString:info[@"albumArt"]];
    
    return track;
}

-(NSString *) displayName
{
    return @"HotNewHipHop";
}

@end
