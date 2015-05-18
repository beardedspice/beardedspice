//
//  LeTournedisqueStrategy.m
//  BeardedSpice
//
//  Created by Jonas Friedmann on 18.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "LeTournedisqueStrategy.h"

@implementation LeTournedisqueStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*letournedisque.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('div.play')[0].click()})();";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('div.prev')[0].click()})();";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('div.next')[0].click()})();";
}

-(NSString *) pause
{
    return @"(function(){return document.querySelectorAll('div.play')[0].click()})();";
}

-(NSString *) displayName
{
    return @"LeTournedisque";
}

@end
