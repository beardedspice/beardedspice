//
//  StitcherStrategy.m
//  BeardedSpice
//
//  Created by Christopher Williams on 3/24/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "StitcherStrategy.h"

@implementation StitcherStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*stitcher.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.stitcher.togglePlay()})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return window.stitcher.skip()})()";
}

-(NSString *) pause
{
    return @"";
}

-(NSString *) displayName
{
    return @"Stitcher";
}

@end
