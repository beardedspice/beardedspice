//
//  BaboomStrategy.m
//  BeardedSpice
//
//  Created by Colin Drake on 8/18/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BaboomStrategy.h"

@implementation BaboomStrategy

- (id)init
{
    self = [super init];
    
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*baboom.com*'"];
    }
    
    return self;
}

- (BOOL)accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (NSString *)toggle
{
    return @"(function(){$('.main-ctrls .btn-ctrl-pause').click()})()";
}

- (NSString *)previous
{
    return @"(function(){$('.icon-previous').click()})()";
}

- (NSString *)next
{
    return @"(function(){$('.icon-next').click()})()";
}

- (NSString *)pause
{
    return @"(function(){$('.main-ctrls .btn-ctrl-pause').click()})()";
}

- (NSString *)displayName
{
    return @"BABOOM";
}


@end
