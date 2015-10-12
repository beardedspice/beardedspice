//
//  PandoraStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "PandoraStrategy.h"

@implementation PandoraStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*pandora.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    NSNumber *value =
    [tab executeJavascript:@"(function(){ var t=document.querySelector('.pauseButton'); return (t.style.display==='block');})()"];
    
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){var e=document.querySelector('.playButton');var t=document.querySelector('.pauseButton');if(t.style.display==='block'){t.click()}else{e.click()}})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"document.querySelector('.skipButton').click();";
}

-(NSString *) pause
{
    return @"document.querySelector('.pauseButton').click();";
}

-(NSString *) displayName
{
    return @"Pandora";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"( function(){ return { \
                          'track': document.querySelector('.playerBarSong').innerText, \
                          'artist': document.querySelector('.playerBarArtist').innerText, \
                          'album': document.querySelector('.playerBarAlbum').innerText, \
                          'image': document.querySelector('.playerBarArt').src }; \
                           })()"];

    Track *track = [[Track alloc] init];
    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.album = info[@"album"];
    track.image = [self imageByUrlString:info[@"image"]];

    return track;
}

@end
