//
//  SoundCloudStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SoundCloudStrategy.h"

@implementation SoundCloudStrategy

-(BOOL) accepts:(id <Tab>)tab
{
    return [[tab URL] isCaseInsensitiveLike:@"*soundcloud.com*"];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('.playControl')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('.skipControl__previous')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('.skipControl__next')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){var play = document.querySelectorAll('.skipControl__next')[0];if(play.classList.contains('sc-button-pause')){play.click();}})()";
}

-(NSString *) displayName
{
    return @"SoundCloud";
}

@end
