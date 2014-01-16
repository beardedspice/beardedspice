//
//  SynologyStrategy.m
//  BeardedSpice
//
//  Created by Stephan van Diepen on 16/01/2014.
//  Copyright (c) 2013 Stephan van Diepen. All rights reserved.
//

#import "SynologyStrategy.h"

@implementation SynologyStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*synology.me*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelectorAll('.player-play button')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelectorAll('.player-prev button')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelectorAll('.player-next button')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){document.querySelectorAll('.player-stop button')[0].click()})()";
}

-(NSString *) displayName
{
    return @"Synology Audio Station";
}


@end
