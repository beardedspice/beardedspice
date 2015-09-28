//
//  NRKStrategy.h
//  BeardedSpice
//
//  Created by Theodor Tonum on 8/24/15.
//  Copyright (c) 2015 Theodor Tonum. All rights reserved.
//

#import "NRKStrategy.h"

@implementation NRKStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*radio.nrk.no*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.nrk.modules.player.getApi().toggleplay()})()";
}

-(NSString *) pause
{
    return @"(function(){return window.nrk.modules.player.getApi().pause()})()";
}

-(NSString *) displayName
{
    return @"NRK";
}

@end
