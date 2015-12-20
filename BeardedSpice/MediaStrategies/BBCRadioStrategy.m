//
//  BBCRadioStrategy.m
//  BeardedSpice
//
//  Created by Max Borghino on 12/13/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

// strategy/site notes
// - no previous and next available on site

#import "BBCRadioStrategy.h"

@implementation BBCRadioStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*bbc.co.uk/radio/player/*'"];
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
                          var s=document.querySelector('#controls');\
                          return (s && (s.classList.contains('stoppable') || s.classList.contains('pausable')));\
                        })();"];

    return [result boolValue];
}

-(NSString *) toggle
{
    return @"\
    (function(){\
      var s=document.querySelector('#controls'),\
        play=document.querySelector('#btn-play'),\
        pause=document.querySelector('#btn-pause');\
      if (s) { (s.classList.contains('stoppable') || s.classList.contains('pausable')) ? pause.click() : play.click(); }\
    })();";
}

- (NSString *)previous {
    return @"";
}

- (NSString *)next {
    return @"";
}

-(NSString *) pause
{
    return @"(function(){document.querySelector('#btn-pause').click();})()";
}

- (NSString *)favorite
{
    return @"(function(){document.querySelector('#toggle-mystations').click();})()";
}

-(NSString *) displayName
{
    return @"BBC Radio";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"\
    (function(){\
      var playlister=document.querySelector('.playlister'),\
        art, title, artist;\
      if (playlister) {\
        art=document.querySelector('.playlister img'),\
        title=playlister.querySelector('.track .title'),\
        artist=playlister.querySelector('.track .artist');\
      } else {\
        art=document.querySelector('#main-image-wrapper img'),\
        title=document.querySelector('#parent-title a'),\
        artist=document.querySelector('#title a');\
      }\
      return {'artSrc': art ? art.getAttribute('src') : null,\
              'title': title ? title.innerText : document.title,\
              'artist': artist ? artist.innerText : null};\
    })()"];

    Track *track = [[Track alloc] init];
    track.track = info[@"title"];
    track.artist = info[@"artist"];
    track.image = [self imageByUrlString:info[@"artSrc"]];

    return track;
}

@end
