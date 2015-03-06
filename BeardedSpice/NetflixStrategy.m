//
//  NetflixStrategy.m
//  BeardedSpice
//
//  Created by Martijn Engler on 3/6/15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NetflixStrategy.h"

@implementation NetflixStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*netflix.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"var v = document.getElementsByTagName('video')[0]; v.paused ? v.play() : v.pause();";
}

-(NSString *) previous
{
    // can not be implemented for Netflix.com
    return @"";
}

-(NSString *) next
{
    // can not be implemented for Netflix.com
    return @"";
}

-(NSString *) displayName
{
    return @"Netflix.com";
}

@end
