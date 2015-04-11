//
//  FocusAtWillStrategy.m
//  BeardedSpice
//
//  Created by Ken Mickles on 1/15/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "FocusAtWillStrategy.h"

@implementation FocusAtWillStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*focusatwill.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('a.play').click()})()";
}

-(NSString *) previous
{
    return nil;
}

-(NSString *) next
{
    return @"(function(){document.querySelector('a.next').click()})()";
}

-(NSString *) pause
{
    return @"(function(){document.querySelector('a.play').click()}})()";
}

-(NSString *) displayName
{
    return @"focus@will";
}

@end
