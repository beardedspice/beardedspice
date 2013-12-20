//
//  GrooveSharkStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GrooveSharkStrategy.h"

@implementation GrooveSharkStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*grooveshark.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.Grooveshark.toggle()})()";
}

-(NSString *) previous
{
    return @"(function(){return window.Grooveshark.previous()})()";
}

-(NSString *) next
{
    return @"(function(){return window.Grooveshark.next()})()";
}

-(NSString *) pause
{
    return @"(function(){return window.Grooveshark.pause()})()";
}

-(NSString *) displayName
{
    return @"Grooveshark";
}

@end
