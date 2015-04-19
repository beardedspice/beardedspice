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
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '▶ * | Chorus.'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab title]];
}

-(NSString *) toggle
{
    return @"(function(){return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.togglePlay() : app.shellView.playerPlay() })()";
}

-(NSString *) previous
{
    return @"(function(){return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.prev() : app.shellView.playerPrev() })()";
}

-(NSString *) next
{
    return @"(function(){return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.next() : app.shellView.playerNext()})()";
}

-(NSString *) pause
{
    return @"(function(){return app.audioStreaming.getPlayer() === 'local' ? app.audioStreaming.pause(): true })()";
}

-(NSString *) displayName
{
    return @"Chorus";
}

@end
