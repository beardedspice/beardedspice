//
//  RdioStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 1/9/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "RdioStrategy.h"

@implementation RdioStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*rdio.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){window.R.player.playPause()})()";
}

-(NSString *) previous
{
    return @"(function(){window.R.player.previous()})()";
}

-(NSString *) next
{
    return @"(function(){window.R.player.next()})()";
}

-(NSString *) pause
{
    return @"(function(){window.R.player.pause()})()";
}

-(NSString *) displayName
{
    return @"Rdio";
}

@end
