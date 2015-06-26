//
//  LaracastsStrategy.m
//  BeardedSpice
//
//  Created by Shane Welldon on 26/06/2015.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "LaracastsStrategy.h"

@implementation LaracastsStrategy

- (id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*laracasts.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    NSNumber *value =
        [tab executeJavascript:@"(function(){return !videojs('laracasts-video_html5_api').paused();})();"];
    
    return [value boolValue];
}

-(NSString *)toggle
{
    return @"(function(){p=videojs('laracasts-video_html5_api');return (p.paused())?p.play():p.pause()})();";
}

-(NSString *)pause
{
    return @"(function(){return videojs('laracasts-video_html5_api').pause()})();";
}

-(NSString *)displayName
{
    return @"Laracasts";
}

@end
