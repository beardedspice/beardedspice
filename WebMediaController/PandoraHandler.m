//
//  PandoraHandler.m
//  WebMediaController
//
//  Created by Jose Falcon on 12/9/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "PandoraHandler.h"

@implementation PandoraHandler

+ (id)initWithTab:(id <Tab>)tab
{
    PandoraHandler *out = [[PandoraHandler alloc] init];
    [out setTab:tab];
    return out;
}

- (BOOL) isPlaying
{
    NSNumber *status = [[super tab] executeJavascript:@"(function(){return document.querySelectorAll('.pauseButton')[0].style.display==='block'})()"];
    
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
    [self.tab executeJavascript:@"(function(){return document.querySelectorAll('.playButton')[0].click()})();"];
}
- (void) pause
{
    [self.tab executeJavascript:@"(function(){return document.querySelectorAll('.pauseButton')[0].click()})();"];
}

- (void)previous
{
    NSLog(@"Pandora does not support previous");
}

-(void)next
{
    NSLog(@"Next on %@", [self.tab title]);
    [self.tab executeJavascript:@"(function(){return document.querySelectorAll('.skipButton')[0].click()})();"];
}

+(BOOL) isValidFor:(NSString *)url
{
    return [url isCaseInsensitiveLike:@"*pandora.com*"];
}

@end