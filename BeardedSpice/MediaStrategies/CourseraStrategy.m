//
//  OdnoklassnikiStrategy.m
//  BeardedSpice
//
//  Created by Andrei Glingeanu on 7/29/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "CourseraStrategy.h"

@implementation CourseraStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*coursera.org*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {

    NSNumber *val = [tab
        executeJavascript:@"(function(){var v = vjs(document.querySelectorAll('.video-js')[0].querySelector('video').id); return ! v.paused();})()"];
    
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){var v = vjs(document.querySelectorAll('.video-js')[0].querySelector('video').id); if (v.paused()) { v.play(); } else { v.pause(); }})()";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('.c-item-side-nav-left .c-block-icon-link')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('.c-item-side-nav-right .c-block-icon-link')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){var v = vjs(document.querySelectorAll('.video-js')[0].querySelector('video').id); v.pause();})()";
}

-(NSString *) displayName
{
    return @"Coursera";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    [track setTrack:[tab executeJavascript:@"document.querySelector('.c-video-title').firstChild.nodeValue"]];
    [track setArtist:@"Coursera"];
    return track;
}

@end
