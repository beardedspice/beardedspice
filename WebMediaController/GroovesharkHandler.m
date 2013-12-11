//
//  GroovesharkHandler.m
//  WebMediaController
//
//  Created by Jose Falcon on 12/9/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GroovesharkHandler.h"

@implementation GroovesharkHandler

+ (id)initWithTab:(Tab *)tab
{
    GroovesharkHandler *out = [[GroovesharkHandler alloc] init];
    [tab retain];
    [out setTab:tab];
    return out;
}

- (BOOL) isPlaying
{
    NSNumber *status = [[super tab] executeJavascript:@"(function(){return window.Grooveshark.getCurrentSongStatus().status==='playing'})()"];
    
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
    [self.tab executeJavascript:@"(function(){return window.Grooveshark.play()})()"];
}
- (void) pause
{
    [self.tab executeJavascript:@"(function(){return window.Grooveshark.pause()})()"];
}

- (void)previous
{
    NSLog(@"Previous on %@", [self.tab title]);
    [self.tab executeJavascript:@"(function(){return window.Grooveshark.previous()})()"];
}

-(void)next
{
    NSLog(@"Next on %@", [self.tab title]);
    [self.tab executeJavascript:@"(function(){return window.Grooveshark.next()})()"];
}

+(BOOL) isValidFor:(NSString *)url
{
    return [url isCaseInsensitiveLike:@"*grooveshark.com*"];
}

@end