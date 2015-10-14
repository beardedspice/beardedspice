//
//  GaanaStrategy.m
//  BeardedSpice
//
//  Created by spiritson on 10/14/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#include "GaanaStrategy.h"

@implementation GaanaStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*gaana.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"document.querySelector('.playerspritecall.playPause').click();;";
}

-(NSString *) previous
{
    return @"document.querySelector('.playerspritecall.prev').click();";
}

-(NSString *) next
{
    return @"document.querySelector('.playerspritecall.next').click();";
}

-(NSString *) pause
{
    return @"document.querySelector('.playerspritecall.playPause').click();";
}

-(NSString *) favorite
{
    return @"document.querySelector('.player_activity>.favorite').click()";
}

-(NSString *) displayName
{
    return @"Gaana";
}

@end