//
//  UdemyStrategy.m
//  BeardedSpice
//
//  Created by Coder-256 on 10/3/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "UdemyStrategy.h"

@implementation UdemyStrategy

/* EDIT: NOT WORKING:
 Javascript to obtain video object:
 var theVideo = $("div.ud-lectureangular > iframe")[0].contentWindow.document.getElementsByTagName("video")[0];
*/

/*
 JQuery seems to not be working, so here's my workaround:
   var theVideo = document.querySelector('div.ud-lectureangular > iframe').contentWindow.document.querySelector('video');
 And for simply getting the iframe:
   var theFrame = document.querySelector('div.ud-lectureangular > iframe');
*/

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*udemy.com/*/lecture/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    
    NSNumber *value =
    [tab executeJavascript:@"(function(){return !(document.querySelector('div.ud-lectureangular > iframe').contentWindow.document.querySelector('video').paused);}())"];
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"((function(){var theVideo = document.querySelector('div.ud-lectureangular > iframe').contentWindow.document.querySelector('video');theVideo.paused?theVideo.play():theVideo.pause();})())";
}

-(NSString *) next
{
    return @"(function(){document.querySelector('div.ud-lectureangular > iframe').parentElement.parentElement.nextElementSibling.querySelector('.next-lecture').click();})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelector('div.ud-lectureangular > iframe').parentElement.parentElement.parentElement.querySelector('.prev-lecture').click();})()";
}

- (NSString *)pause {
    return @"(function(){document.querySelector('div.ud-lectureangular > iframe').contentWindow.document.querySelector('video').pause()})()";
}

-(NSString *) displayName
{
    return @"Udemy";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    Track *track = [[Track alloc] init];
    
    track.track = [tab executeJavascript:@"$('.curriculum-item.on .ci-title').get(0).innerText;"];
    track.album = [self displayName];
    
    return track;
}

@end
