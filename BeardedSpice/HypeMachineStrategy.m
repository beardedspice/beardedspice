//
//  HypeMachineStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "HypeMachineStrategy.h"

@implementation HypeMachineStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*hypem.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.togglePlay()})()";
}

-(NSString *) previous
{
    return @"(function(){return window.prevTrack()})()";
}

-(NSString *) next
{
    return @"(function(){return window.nextTrack()})()";
}

-(NSString *) pause
{
    return @"(function(){return window.currentPlayerObj[0].pause()})()";
}

-(NSString *) displayName
{
    return @"HypeMachine";
}

@end
