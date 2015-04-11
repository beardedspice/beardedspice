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
    return @"document.getElementById('playpausebutton').click();";
}

-(NSString *) previous
{
    return @"document.getElementById('seekbackbutton').click();";
}

-(NSString *) next
{
    return @"document.getElementById('seekforwardbutton').click();";
}

-(NSString *) displayName
{
    return @"Overcast.fm";
}

@end
