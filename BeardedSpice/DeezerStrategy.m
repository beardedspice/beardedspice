//
//  DeezerStrategy.m
//  BeardedSpice
//
//  Created by Greg Woodcock on 06/01/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "DeezerStrategy.h"

@implementation DeezerStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*deezer.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelectorAll('[data-action=pause], [data-action=play]')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelectorAll('[data-action=prevSong]')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelectorAll('[data-action=nextSong]')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){var e=document.querySelectorAll('[data-action=pause]')[0];if(dzPlayer.isPlaying()){e.click()}})()";
}

-(NSString *) displayName
{
    return @"Deezer";
}

@end
