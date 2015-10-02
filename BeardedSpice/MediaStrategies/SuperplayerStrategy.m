//
//  SuperplayerStrategy.m
//  BeardedSpice
//
//  Created by Thiago Dorneles on 10/2/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "SuperplayerStrategy.h"

@implementation SuperplayerStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*https://www.superplayer.fm/player?playing*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('.main.primary button[data-action=\"pause\"]').click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelector('.main.primary button[data-action=\"skip\"]').click()})()";
}

-(NSString *) pause
{
    return self.toggle;
}

-(NSString *) favorite
{
    return @"(function(){document.querySelector('.main.secondary button[data-action=\"love\"]').click()})()";
}

-(NSString *) displayName
{
    return @"Superplayer";
}

@end
