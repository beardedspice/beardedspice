//
//  BopFm.m
//  BeardedSpice
//
//  Created by Jose Falcon on 7/22/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "BopFm.h"

@implementation BopFm

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*bop.fm*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){Bop.Player.play()})();";
}

-(NSString *) previous
{
    return @"(function(){Bop.Player.prev()})();";
}

-(NSString *) next
{
    return @"(function(){Bop.Player.next()})();";
}

-(NSString *) favorite
{
    return @"(function (){Bop.User.toggleFavorite()})()";
}


-(NSString *) pause
{
    return @"(function(){Bop.Player.pause()})();";
}

-(NSString *) displayName
{
    return @"Bop.fm";
}

@end
