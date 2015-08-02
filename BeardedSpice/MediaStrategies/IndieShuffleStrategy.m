//
//  IndieShuffleStrategy.m
//  BeardedSpice
//
//  Created by David Davis on 2015-06-30.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "IndieShuffleStrategy.h"

@implementation IndieShuffleStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*indieshuffle.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{

    NSNumber *result = [tab executeJavascript:@"(function(){return document.querySelector('#currentSong .commontrack.active') != undefined;})();"];
    
    return [result boolValue];
}


-(NSString *) toggle
{
    return @"(function(){document.querySelector('#currentSong .commontrack').click()})()";
}

-(NSString *) previous
{
    return @"(function(){if(p=document.querySelector('#prevSong .song_artwork')){p.click();}})()";
}

-(NSString *) next
{
    return @"(function(){if(p=document.querySelector('#playNextSong')){p.click();}})()";
}

-(NSString *) pause
{
    return @"(function(){if(p=document.querySelector('#currentSong .commontrack.active')){p.click();}})()";
}

- (NSString *)favorite
{
    return @"";
}

-(NSString *) displayName
{
    return @"IndieShuffle";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){var song=document.querySelector('#currentSong'); return {'artist': song.querySelector('.artist_name').innerText, 'track': song.querySelector('.song-details').innerText, 'img':song.querySelector('img.song_artwork').getAttribute('src')}})()"];

    Track *track = [[Track alloc] init];

    track.track = info[
                       @"track"];
    track.artist = info[@"artist"];
    track.image = [self imageByUrlString:info[@"img"]];

    return track;
}

@end
