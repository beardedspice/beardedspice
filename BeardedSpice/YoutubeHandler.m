//
//  YoutubeHandler.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YoutubeHandler.h"

@implementation YoutubeHandler

+ (id)initWithTab:(id <Tab>)tab
{
    YoutubeHandler *out = [[YoutubeHandler alloc] init];
    [out setTab:tab];
    return out;
}

- (BOOL) isPlaying
{
    NSNumber *status = [[super tab] executeJavascript:@"(function(){var e=0,t=0,n=document.querySelectorAll('#movie_player');for(e=0;e<n.length;e++){t=n[e].getPlayerState();break}return t;})()"];
    if (status) {
        NSLog(@"Status is %@", status);
        return [status intValue] == 1;
    } else {
        NSLog(@"Status is not defined!");
        return NO;
    }
}

- (void)toggle
{
    NSLog(@"Toggle on %@", [self.tab title]);
    if ([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void) play
{
    [self.tab executeJavascript:@"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){t[e].playVideo()}})()"];
}
- (void) pause
{
    [self.tab executeJavascript:@"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){t[e].pauseVideo()}})()"];
}

- (void)previous
{
    NSLog(@"Previous on %@", [self.tab title]);
    [self.tab executeJavascript:@"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){t[e].previousVideo()}})()"];
}

-(void)next
{
    NSLog(@"Next on %@", [self.tab title]);
    [self.tab executeJavascript:@"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){t[e].nextVideo()}})()"];
}

+(BOOL) isValidFor:(NSString *)url
{
    return [url isCaseInsensitiveLike:@"*youtube.com/watch*"];
}

@end
