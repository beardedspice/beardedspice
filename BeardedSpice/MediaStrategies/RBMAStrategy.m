//
//  RBMAStrategy.m
//  BeardedSpice
//
//  Created by Jeremy Miller on 8/29/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "RBMAStrategy.h"

@implementation RBMAStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*rbmaradio.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    
    NSNumber *value =
        [tab executeJavascript:@"(function()"
                               @"{return $('.controls').attr('data-state') == 'playing'"
                               @"?true:false;})()"];
    
    return [value boolValue];
}

-(NSString *) toggle {
    return @"(function(){return $('.play-button').trigger('click')})()";
}

-(NSString *) pause
{
    return @"(function(){\
    if($('.controls').attr('data-state') == 'playing'){\
    return $('.play-button').trigger('click')\
    }else{\
    }})()";
}

-(NSString *) displayName
{
    return @"RBMA";
}

@end
