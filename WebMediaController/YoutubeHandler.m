//
//  YoutubeHandler.m
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YoutubeHandler.h"

@implementation YoutubeHandler

- (void)play:(ChromeTab *)tab
{
    NSLog(@"Play on %@", tab);
    [tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('video'); for (i = 0; i < vs.length; i++) { vs[i].play() }"];
    [tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('#movie_player'); for (i = 0; i < vs.length; i++) { vs[i].playVideo() }"];
}

- (void)pause:(ChromeTab *)tab
{
    NSLog(@"Pause on %@", tab);
    
    [tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('video'); for (i = 0; i < vs.length; i++) { vs[i].pause() }"];
    [tab executeJavascript:@"var i = 0, vs = document.querySelectorAll('#movie_player'); for (i = 0; i < vs.length; i++) { vs[i].stopVideo() }"];
}

- (void)previous:(ChromeTab *)tab
{
    NSLog(@"Previous on %@", tab);
}

-(void)next:(ChromeTab *)tab
{
    NSLog(@"Next on %@", tab);    
}
@end
