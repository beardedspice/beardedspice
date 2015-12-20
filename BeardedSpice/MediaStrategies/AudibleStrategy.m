//
//  AudibleStrategy.m
//  BeardedSpice
//
//  Created by Max Borghino on 12/06/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

// strategy/site notes
// - favorite: sets a bookmark
// - prev: implements skip back 30 seconds
// - next: not used (alternative: we could do prev/next chapter, but this is not very useful)
// - track info: book title and author not in the player, only artwork, chapter, time/time left

#import "AudibleStrategy.h"

@implementation AudibleStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*audible.com/cloud-player*'"];
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
                          var p=document.querySelector('.pause');\
                          return (p && !p.classList.contains('hide'));\
                        })();"];

    return [result boolValue];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('.play').click();})()";
}

- (NSString *)previous {
    return @"(function(){document.querySelector('.repeat').click()})()";
}

- (NSString *)next {
    return @"";
}

-(NSString *) pause
{
    return @"\
    (function(){\
      var p=document.querySelector('.pause');\
      if(p && !p.classList.contains('hide')){ p.click();}\
    })()";
}

- (NSString *)favorite
{
    // favorite sets a bookmark
    return @"(function(){document.querySelector('.fav').click();})()";
}

-(NSString *) displayName
{
    return @"Audible";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"\
                          (function(){\
                            var art=document.querySelector('.item img'),\
                                chapter=document.querySelector('.chapter'),\
                                timeCur=document.querySelector('.cur'),\
                                timeRem=document.querySelector('.rem');\
                            return {'artSrc': art ? art.getAttribute('src') : null,\
                                    'chapter': chapter ? chapter.innerText : null,\
                                    'timeCur': timeCur ? timeCur.innerText : null,\
                                    'timeRem': timeRem ? timeRem.innerText : null};\
                          })()"];

    // author and title not available, we'll time data and chapter as it is useful, also no favorite
    Track *track = [[Track alloc] init];
    track.track = info[@"chapter"];
    track.artist = [NSString stringWithFormat:@"%@ / %@", info[@"timeCur"], info[@"timeRem"]];
    track.image = [self imageByUrlString:info[@"artSrc"]];

    return track;
}

@end
