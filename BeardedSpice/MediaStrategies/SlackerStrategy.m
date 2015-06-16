//
//  SlackerStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 1/18/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SlackerStrategy.h"

@implementation SlackerStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*slacker.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){window.playPause()})()";
}

-(NSString *) previous
{
    return @"(function(){window.skipBack()})()";
}

-(NSString *) next
{
    return @"(function(){window.skip()})()";
}

-(NSString *) pause
{
    return @"(function(){window.PLAYER_ENGINE.pause()})()";
}

-(NSString *) displayName
{
    return @"Slacker";
}

@end
