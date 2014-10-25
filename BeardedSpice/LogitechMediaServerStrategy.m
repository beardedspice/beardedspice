//
//  MediaStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "LogitechMediaServerStrategy.h"

@implementation LogitechMediaServerStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*192.168.178.23*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.SqueezeJS.Controller.togglePause()})()";
}

-(NSString *) previous
{
    return @"(function(){return window.SqueezeJS.Controller.playerControl(['button', 'jump_rew'])})()";
}

-(NSString *) next
{
    return @"(function(){return window.SqueezeJS.Controller.playerControl(['button', 'jump_fwd'])})()";
}

-(NSString *) pause
{
    return @"(function(){return window.SqueezeJS.Controller.playerControl(['pause'])})()";
}

-(NSString *) displayName
{
    return @"Logitech Media Server";
}

@end