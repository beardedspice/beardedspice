//
//  YoutubeHandler.m
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YoutubeHandler.h"

@implementation YoutubeHandler

+ (id)initWithTab:(ChromeTab *)tab
{
    return [super initWithTab:tab];
}

- (BOOL) isPlaying
{
    int *status = (int *)[self.tab executeJavascript:@"function () {var i = 0, vs = document.querySelectorAll('#movie_player'); for (i = 0; i < vs.length; i++) { return vs[i].getPlayerStatus() }}();"];
    if (status) {
        NSLog(@"Status is %d", *status);
    } else {
        NSLog(@"Status is not defined!");
    }
    return TRUE;
}

- (void)toggle
{
    NSLog(@"Toggle on %@", [self tab]);
    if ([self isPlaying]) {
        [self play];
    } else {
        [self pause];
    }
}

- (void) play
{
    [self.tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('video'); for (i = 0; i < vs.length; i++) { vs[i].play() }"];
    [self.tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('#movie_player'); for (i = 0; i < vs.length; i++) { vs[i].playVideo() }"];
}
- (void) pause
{
    [self.tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('video'); for (i = 0; i < vs.length; i++) { vs[i].pause() }"];
    [self.tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('#movie_player'); for (i = 0; i < vs.length; i++) { vs[i].pauseVideo() }"];
}

- (void)previous
{
    NSLog(@"Previous on %@", self.tab);
}

-(void)next
{
    NSLog(@"Next on %@", self.tab);
}

+(BOOL) isValidFor:(NSString *)url
{
    return [url isCaseInsensitiveLike:@"*youtube*"];
}

@end
