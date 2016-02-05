//
//  OvercastStrategy.m
//  BeardedSpice
//
//  Created by Alan Clark 08/06/2014
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

// strategy/site notes
// - favorite: not implemented by site

#import "OvercastStrategy.h"

@implementation OvercastStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*overcast.fm*'"];
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
                        var p=document.querySelector('#playpausebutton_playicon');\
                        return (p && p.style.display==='none');\
                        })();"];

    return [result boolValue];
}

-(NSString *) toggle
{
    return @"document.getElementById('playpausebutton').click();";
}

-(NSString *) previous
{
    return @"document.getElementById('seekbackbutton').click();";
}

-(NSString *) next
{
    return @"document.getElementById('seekforwardbutton').click();";
}

-(NSString *) pause
{
    return @"\
    (function(){\
    var p=document.querySelector('#playpausebutton_playicon');\
    if(p && p.style.display==='none'){ document.getElementById('playpausebutton').click();}\
    })()";
}

-(NSString *) displayName
{
    return @"Overcast.fm";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"\
                          (function(){\
                          var artist=document.querySelector('.caption2 a'),\
                          track=document.querySelector('.title'),\
                          art=document.querySelector('.art.fullart');\
                          return {'artist': artist ? artist.innerText : null,\
                          'track': track ? track.innerText : null,\
                          'artSrc': art ? art.getAttribute('src') : null};\
                          })()"];

    // author and title not available, we'll time data and chapter as it is useful, also no favorite
    Track *track = [[Track alloc] init];
    track.artist = info[@"artist"];
    track.track = info[@"track"];
    track.image = [self imageByUrlString:info[@"artSrc"]];

    return track;
}

@end
