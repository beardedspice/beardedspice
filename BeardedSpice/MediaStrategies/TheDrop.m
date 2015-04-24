//
//  TheDrop.m
//  BeardedSpice
//
//  Created by Dominic Damian on 4/23/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TheDrop.h"

@implementation TheDropStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*thedrop.club*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){var play=document.querySelector('.music-player .container .play-button');\
    if (play!=null) {play.click()} else { document.querySelector('.music-player .container .pause-button').click() }})()";
}

-(NSString *) pause
{
    // NOTE: this will fail if we are already paused, but that's fine.
    return @"(function(){var pause=document.querySelector('.music-player .container .pause-button');\
    if (pause!=null) {pause.click()} else { document.querySelector('.music-player .container .play-button').click() } })()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelector('.music-player .container prev-button').click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelector('.music-player .container .next-button').click()})()";
}

-(NSString *) favorite
{
    return @"(function(){document.querySelector('.music-player .container .favorite-button').click()})()";
}

-(NSString *) displayName
{
    return @"TheDrop";
}

@end
