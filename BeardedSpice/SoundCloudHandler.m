//
//  SoundCloudHandler.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/13/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SoundCloudHandler.h"

@implementation SoundCloudHandler

+ (id)initWithTab:(id <Tab>)tab
{
    SoundCloudHandler *out = [[SoundCloudHandler alloc] init];
    [out setTab:tab];
    return out;
}

- (BOOL) isPlaying
{
    NSNumber *status = [[super tab] executeJavascript:@"(function(){return document.querySelectorAll('.playControl')[0].classList.contains('playing')})()"];
    
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
    [self.tab executeJavascript:@"(function(){return document.querySelectorAll('.playControl')[0].click()})()"];
}
- (void) pause
{
    [self.tab executeJavascript:@"(function(){return document.querySelectorAll('.playControl')[0].click()})()"];
}

- (void)previous
{
    NSLog(@"Previous on %@", [self.tab title]);
    [self.tab executeJavascript:@"(function(){return document.querySelectorAll('.skipControl__previous')[0].click()})()"];
}

-(void)next
{
    NSLog(@"Next on %@", [self.tab title]);
    [self.tab executeJavascript:@"(function(){return document.querySelectorAll('.skipControl__next')[0].click()})()"];
}

+(BOOL) isValidFor:(NSString *)url
{
    return [url isCaseInsensitiveLike:@"*soundcloud.com*"];
}

@end
