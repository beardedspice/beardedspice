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
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] 'Logitech Media Server'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab title]];
}

-(NSString *) toggle
{
    return @"(function(){return window.SqueezeJS.Controller.togglePause()})()";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('#ctrlPrevious button')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('#ctrlNext button')[0].click()})()";
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