//
//  BugsMediaStrategy.m
//  BeardedSpice
//
//  Created by Hoseong Son on 12/31/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "BugsStrategy.h"

@implementation BugsStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*music.bugs.co.kr/newPlayer*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){var e=document.querySelectorAll('.btnPlay button')[0];var t=document.querySelectorAll('.btnStop button')[0];if(e!=null){e.click()}else{t.click()}})()";
}

- (NSString *)previous {
    return @"(function(){var e=document.querySelectorAll('.btnPrev button')[0]; e.click()})()";
}

- (NSString *)next {
    return @"(function(){var e=document.querySelectorAll('.btnNext button')[0]; e.click()})()";
}

-(NSString *) pause
{
    return @"(function(){var t=document.querySelectorAll('.btnStop button')[0].click()})()";
}

- (NSString *)favorite
{
    return @"";
}

-(NSString *) displayName
{
    return @"Bugs";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){return { \
                          'title':  document.querySelectorAll('.tracktitle')[0].innerText, \
                          'album':  document.querySelectorAll('.albumtitle')[0].innerText, \
                          'artist': document.querySelectorAll('#newPlayerArtistName')[0].innerText, \
                          'artSrc':  document.querySelectorAll('.thumbnail img')[0].getAttribute('src')} \
                          })()"];
    
    Track *track = [[Track alloc] init];
    track.track = info[@"title"];
    track.artist = info[@"artist"];
    track.image = [self imageByUrlString:info[@"artSrc"]];
    
    return track;
}
@end
