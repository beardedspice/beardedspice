//
//  EightTracksStrategy.m
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/15/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "EightTracksStrategy.h"

@implementation EightTracksStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*8tracks.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){window.mixPlayer.toggle()})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){window.mixPlayer.next()})()";
}

-(NSString *) pause
{
    return @"(function(){window.mixPlayer.pause()})()";
}

-(NSString *) displayName
{
    return @"8tracks";
}

@end
