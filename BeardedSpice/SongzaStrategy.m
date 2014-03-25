//
//  SongzaStrategy.m
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/18/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SongzaStrategy.h"

@implementation SongzaStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*songza.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('.miniplayer-control-play-pause').click();})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelector('.miniplayer-control-skip').click()})()";
}

-(NSString *) pause
{
    return @"(function(){ if (document.querySelector('.player-wrapper').classList.contains('player-state-play')) document.querySelector('.miniplayer-control-play-pause').click()})()";
}

-(NSString *) displayName
{
    return @"Songza";
}

@end
