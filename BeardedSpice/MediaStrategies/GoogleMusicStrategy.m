//
//  GoogleMusicStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 1/9/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GoogleMusicStrategy.h"

@implementation GoogleMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*play.google.com/music/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{

    NSNumber *result = [tab executeJavascript:@"(function(){var e=document.querySelector('[data-id=play-pause]');return e.classList.contains('playing')})()"];

    return [result boolValue];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('[data-id=play-pause]').click()})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelector('[data-id=rewind]').click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelector('[data-id=forward]').click()})()";
}

-(NSString *) pause
{
    return @"(function(){var e=document.querySelector('[data-id=play-pause]');if(e.classList.contains('playing')){e.click()}})()";
}

- (NSString *)favorite
{
    return @"(function(){document.querySelector('paper-icon-button[data-rating=\"5\"]').click()})()";
}

-(NSString *) displayName
{
    return @"GoogleMusic";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *song = [tab executeJavascript:@"(function(){return { \
                          'track':  document.getElementById('currently-playing-title').innerText, \
                          'album':  document.getElementsByClassName('player-album')[0].innerText, \
                          'artist': document.getElementById('player-artist').innerText, \
                          'image':  document.getElementById('playerBarArt').getAttribute('src')} \
                          })()"];
    
    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    track.album = [song objectForKey:@"album"];
    track.artist = [song objectForKey:@"artist"];
    track.image = [self imageByUrlString:song[@"image"]];

    return track;
}

@end
