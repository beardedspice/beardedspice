//
//  VimeoStrategy.m
//  BeardedSpice
//
//  Created by Antoine Hanriat on 08/08/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "VimeoStrategy.h"

@implementation VimeoStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*vimeo.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){return window.vimeo.active_player.paused?window.vimeo.active_player.play():window.vimeo.active_player.pause()})()";
}

-(NSString *) previous
{
    return @""; // Not available
}

-(NSString *) next
{
    return @""; // Not available
}

-(NSString *) pause
{
    return @"(function(){return window.vimeo.active_player.pause()})()";
}

-(NSString *) displayName
{
    return @"Vimeo";
}



@end
