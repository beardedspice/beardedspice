//
//  DeezerStrategy.m
//  BeardedSpice
//
//  Created by Greg Woodcock on 06/01/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "DeezerStrategy.h"

@implementation DeezerStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*deezer.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){dzPlayer.control.togglePause()})()";
}

-(NSString *) previous
{
    return @"(function(){dzPlayer.control.prevSong()})()";
}

-(NSString *) next
{
    return @"(function(){dzPlayer.control.nextSong()})()";
}

-(NSString *) favorite
{
    return @"(function (){return document.querySelectorAll('a.icon-love-circle')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){dzPlayer.control.pause()})()";
}

-(NSString *) displayName
{
    return @"Deezer";
}

@end
