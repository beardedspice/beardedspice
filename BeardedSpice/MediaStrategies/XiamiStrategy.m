//
//  XiamiStrategy.m
//  BeardedSpice
//
//  Created by Weslly on 4/2/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "XiamiStrategy.h"

@implementation XiamiStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*xiami.com/play*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    NSNumber *value =
    [tab executeJavascript:@"(function(){ var t=document.querySelector('.pause-btn'); return (t.style.display==='block');})()"];
    
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"document.querySelector('#J_playBtn').click();";
}

-(NSString *) previous
{
    return @"document.querySelector('.prev-btn').click();";
}

-(NSString *) next
{
    return @"document.querySelector('.next-btn').click();";
}

-(NSString *) pause
{
    return @"document.querySelector('.pause-btn').click();";
}

-(NSString *) displayName
{
    return @"Xiami";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"( function(){ return { \
                          'track': document.querySelector('#J_trackName').innerText, \
                          'artist': document.querySelector('#J_trackName + a').innerText, \
                          'album': document.querySelector('#J_playerCoverImg').alt.replace('-' + document.querySelector('#J_trackName + a').innerText, ''), \
                          'image': document.querySelector('#J_playerCoverImg').src }; \
                          })()"];
    
    Track *track = [[Track alloc] init];
    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.album = info[@"album"];
    track.image = [self imageByUrlString:info[@"image"]];
    
    return track;
}

@end
