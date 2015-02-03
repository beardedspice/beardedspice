//
//  WonderFmStrategy.m
//  BeardedSpice
//
//  Created by Kyle Conarro on 2/3/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "WonderFmStrategy.h"

@implementation WonderFmStrategy


-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*wonder.fm*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function() {var playButton = document.querySelector('a.jp-play');var pauseButton = document.querySelector('a.jp-pause');if (playButton.style.cssText === 'display: none;') {pauseButton.click();} else {playButton.click();}})()";
}

-(NSString *) previous
{
    return @""; // Not available
}

-(NSString *) next
{
     return @"(function(){document.querySelector('a.jp-next').click()})()";
}

-(NSString *) pause
{
     return @"(function(){document.querySelector('a.jp-pause').click()})()";
}

-(NSString *) displayName
{
    return @"WonderFM";
}

@end
