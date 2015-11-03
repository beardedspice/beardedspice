//
//  UdemyStrategy.m
//  BeardedSpice
//
//  Created by Coder-256 on 10/3/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "UdemyStrategy.h"

@implementation UdemyStrategy

/*
 Javascript to obtain video object:
 var theVideo = $("div.ud-lectureangular > iframe")[0].contentWindow.document.getElementsByTagName("video")[0];
*/

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*udemy.com*/lecture/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    
    NSNumber *value =
    [tab executeJavascript:@"(function(){return !($(\"div.ud-lectureangular > iframe\")[0].contentWindow.document.getElementsByTagName(\"video\")[0].paused);})()"];
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){var theVideo = $(\"div.ud-lectureangular > iframe\")[0].contentWindow.document.getElementsByTagName(\"video\")[0]; \
        if(theVideo.paused){theVideo.play();}else{theVideo.pause()}})()";
}

-(NSString *) next
{
    return @"(function(){$(\"div.ud-lectureangular > iframe\").parent().parent().next().find(\".next-lecture\")[0].click();})()";
}

-(NSString *) previous
{
    return @"(function(){$(\"div.ud-lectureangular > iframe\").parent().parent().parent().find(\".prev-lecture\")[0].click();})()";
}

- (NSString *)pause {
    return @"(function(){$(\"div.ud-lectureangular > iframe\")[0].contentWindow.document.getElementsByTagName(\"video\")[0].pause()})()";
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
