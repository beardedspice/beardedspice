//
//  BeatsMusicStrategy.m
//  BeardedSpice
//
//  Created by John Bruer on 1/27/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "BeatsMusicStrategy.h"

@implementation BeatsMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*listen.beatsmusic.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelectorAll('#t-play')[0].click()})();";
}

-(NSString *) previous
{
    return @"(function(){document.querySelectorAll('#t-prev')[0].click()})();";
}

-(NSString *) next
{
    return @"(function(){document.querySelectorAll('#t-next')[0].click()})();";
}

-(NSString *) pause
{
    // this will pause the track, but it won't update the play/puase button state
    return @"(function(){window.sm.pauseAll()})();";
}

-(NSString *) displayName
{
    return @"Beats Music";
}

@end
