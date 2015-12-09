//
//  NetflixStrategy.m
//  BeardedSpice
//
//  Created by Max Borghino on 12/06/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

// strategy/site notes
// - favorite, not implemented on this site
// - next/prev not solved here, TODO: send left/right arrow key events for 10 second skips
// - track info consists only of the show name, no artist or artwork

#import "NetflixStrategy.h"

@implementation NetflixStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*netflix.com/watch/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{

    NSNumber *result = [tab executeJavascript:@"\
                        (function(){\
                          var v=document.querySelector('video');\
                          return v && !v.paused;\
                        })();"];

    return [result boolValue];
}

-(NSString *) toggle
{
    return @"\
    (function(){\
      var v=document.querySelector('video');\
      if (v) {v.paused ? v.play() : v.pause();}\
    })()";
}

- (NSString *)previous {
    return @"";
}

- (NSString *)next {
    return @"";
}

-(NSString *) pause
{
    return @"\
    (function(){\
      var v=document.querySelector('video');\
      v && v.pause();\
    })()";
}

-(NSString *) displayName
{
    return @"Netflix";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"\
                          (function(){\
                            var track=document.querySelector('.player-status-main-title');\
                            return {'track': track ? track.innerText : ''}\
                          })()"];

    Track *track = [[Track alloc] init];
    track.track = info[@"track"];
    // there is no track album art, artist, fav

    return track;
}

@end
