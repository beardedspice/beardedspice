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
    return @"(function(){var play=document.querySelector('.player-play');var pause=document.querySelector('.player-pause');if(document.querySelector('.sz-player').classList.contains('sz-player-play-state-pause')){play.click()}else{pause.click()}})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelector('.player-skip').click()})()";
}

-(NSString *) pause
{
    return @"(function(){ return document.querySelector('.player-pause').click()})()";
}

-(NSString *) displayName
{
    return @"Songza";
}

@end
