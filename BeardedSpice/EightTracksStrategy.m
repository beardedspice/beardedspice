//
//  EightTracksStrategy.m
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/15/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "EightTracksStrategy.h"

@implementation EightTracksStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*8tracks.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){var play=document.querySelectorAll('#player_play_button')[0];var pause=document.querySelectorAll('#player_pause_button')[0];if(play.style.display==='block'){play.click()}else{pause.click()}})()";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('#player_skip_button')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){ return document.querySelectorAll('#player_pause_button')[0].click()})()";
}

-(NSString *) displayName
{
    return @"8tracks";
}

@end
