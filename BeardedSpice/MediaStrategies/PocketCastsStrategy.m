//
//  PocketCastsStrategy.m
//  BeardedSpice
//
//  Created by Dmytro Piliugin on 1/23/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "PocketCastsStrategy.h"

@implementation PocketCastsStrategy


-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*play.pocketcasts.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('div.play_pause_button').click()})()";
}

-(NSString *) previous
{
     return @"(function(){document.querySelector('div.skip_back_button').click()})()";
}

-(NSString *) next
{
     return @"(function(){document.querySelector('div.skip_forward_button').click()})()";
}

-(NSString *) pause
{
     return @"(function(){document.querySelector('div.pause_button').click()})()";
}

-(NSString *) displayName
{
    return @"PocketCasts";
}

@end