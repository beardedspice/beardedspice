//
//  BrainFmStrategy.m
//  BeardedSpice
//
//  Created by James Greenleaf on 03/05/16.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "BrainFmStrategy.h"

@implementation BrainFmStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*brain.fm/app*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL) isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab
                     executeJavascript:@"(function(){var p=document.querySelector('#play_button');return p.classList.contains('tc_pause');})()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelectorAll('#play_button')[0].click();})();";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('#skip_button')[0].click()})();";
}

-(NSString *) pause
{
    return @"(function(){var p=document.querySelectorAll('#play_button')[0];if(p.classList.contains('tc_pause')){p.click();}})();";
}

-(NSString *) displayName
{
    return @"Brain.fm";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    NSDictionary *song =
    [tab executeJavascript:@"(function(){return{track:document.querySelector('#playing_title').textContent}})();"];
    
    Track *track = [[Track alloc] init];
    track.track = [song objectForKey:@"track"];
    
    return track;
}

@end
