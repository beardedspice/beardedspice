//
//  PakartotStrategy.m
//  BeardedSpice
//
//  Created by monai on 2015-08-05.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "PakartotStrategy.h"

@implementation PakartotStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*pakartot.lt*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    
    NSNumber *value = [tab executeJavascript:@"(function(){return $('#playernode').data().jPlayer.status.paused;})()"];
    
    return [value boolValue];
}


-(NSString *) toggle
{
    return
    @"(function(){"
    @"var action = $('#playernode').data().jPlayer.status.paused ? 'play' : 'pause';"
    @"$('#playernode').jPlayer(action);"
    @"})()";
}

-(NSString *) previous
{
    return @"(function(){$('.jp-previous').click();})()";
}

-(NSString *) next
{
    return @"(function(){$('.jp-next').click();})()";
}

-(NSString *) favorite
{
    return @"(function(){$('.jp-love').click();})()";
}

-(NSString *) pause
{
    return @"(function(){$('#playernode').jPlayer('pause');})()";
}

-(NSString *) displayName
{
    return @"Pakartot";
}

@end
