//
//  ChorusStrategy.m
//  BeardedSpice
//
//  Created by Mark Reid on 10/01/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ChorusStrategy.h"

@implementation ChorusStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*Chorus.*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab title]];
}

-(NSString *) toggle
{
    return @"(function(){return app.audioStreaming.togglePlay();})()";
}

-(NSString *) previous
{
    return @"(function(){return app.audioStreaming.prev()})()";
}

-(NSString *) next
{
    return @"(function(){return app.audioStreaming.next()})()";
}

-(NSString *) pause
{
    return @"(function(){return app.audioStreaming.pause()})()";
}

-(NSString *) displayName
{
    return @"Chorus";
}

@end
