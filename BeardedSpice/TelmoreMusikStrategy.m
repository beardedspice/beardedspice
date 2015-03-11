//
//  TelmoreMusikStrategy.m
//  BeardedSpice
//
//  Created by Jesper Skytte Hansen on 3/11/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TelmoreMusikStrategy.h"

@implementation TelmoreMusikStrategy


-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*musik.telmore.dk*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){player.pause();return false})()";
}

-(NSString *) previous
{
     return @"(function(){player.previous();return false;})()";
}

-(NSString *) next
{
     return @"(function(){player.next();return false;})()";
}

-(NSString *) pause
{
     return @"(function(){player.pause();return false;})()";
}

-(NSString *) displayName
{
    return @"TELMORE Musik";
}

@end