//
//  TwentyTwoTracksStrategy.m
//  BeardedSpice
//
//  Created by Jan Pochyla on 08/26/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TwentyTwoTracksStrategy.h"

@implementation TwentyTwoTracksStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*22tracks.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){angular.element(document.querySelector('.player .ng-scope')).scope().Audio.playpause()})()";
}

-(NSString *) previous
{
    return @"(function(){angular.element(document.querySelector('.player .ng-scope')).scope().Audio.previous()})()";
}

-(NSString *) next
{
    return @"(function(){angular.element(document.querySelector('.player .ng-scope')).scope().Audio.next()})()";
}

-(NSString *) pause
{
    return @"(function(){angular.element(document.querySelector('.player .ng-scope')).scope().Audio.pause()})()";
}

-(NSString *) displayName
{
    return @"22tracks";
}

@end
