//
//  TTNETMuzik.m
//  BeardedSpice
//
//  Created by Bilal Demirci on 08/03/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "TTMuzik.h"

@implementation TTMuzik

- (id)init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*turktelekommuzik.com*'"];
    }
    return self;
}

- (BOOL)accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (NSString *)toggle
{
    return @"(function(){document.querySelector('#player-play').click()})()";
}

- (NSString *)previous
{
    return @"(function(){document.querySelector('#player-prev').click()})()";
}

- (NSString *)next
{
    return @"(function(){document.querySelector('#player-next').click()})()";
}

- (NSString *)pause
{
    return @"(function(){document.querySelector('#player-play').click()})()";
}

- (NSString *)displayName
{
    return @"TT Muzik";
}





/**
 Checks tab to see if it is currently playing audio.
 */
- (BOOL)isPlaying:(TabAdapter *)tab
{
    return YES;
}

/**
 Returns track information object from tab. More information below.
 */
//- (Track *)trackInfo:(TabAdapter *)tab
//{
//    
//}


@end
