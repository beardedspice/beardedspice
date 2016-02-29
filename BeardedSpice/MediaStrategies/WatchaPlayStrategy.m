//
//  WatchaPlayStrategy.m
//  BeardedSpice
//
//  Created by KimJongMin on 2016. 3. 1..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//
// strategy/site notes
// - favorite, not implemented on this site
// - next/prev not solved here, TODO: send left/right arrow key events for 5 second skips

#import "WatchaPlayStrategy.h"

@implementation WatchaPlayStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*play.watcha.net/watch*'"];
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
    return @"Watcha Play";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"\
                          (function(){\
                          var track=document.querySelector('.vjs-display');\
                          return {'track': track ? track.innerText : ''}\
                          })()"];

    Track *track = [[Track alloc] init];
    track.track = info[@"track"];

    return track;
}
@end