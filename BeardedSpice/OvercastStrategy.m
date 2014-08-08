//
//  OvercastStrategy.m
//  BeardedSpice
//
//  Created by Alan Clark 08/06/2014
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "OvercastStrategy.h"

@implementation OvercastStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*overcast.fm*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"var p=document.getElementById('audioplayer'); if(p.paused){ p.play();}else{p.pause();}";
}

-(NSString *) displayName
{
    return @"Overcast.fm";
}

@end