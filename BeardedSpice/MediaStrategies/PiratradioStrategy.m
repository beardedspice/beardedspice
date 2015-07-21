//
//  PiratradioStrategy.m
//  BeardedSpice
//
//  Created by Axel Smeets on 21/07/15.
//  Copyright (c) 2015 Axel Smeets. All rights reserved.
//

#import "PiratradioStrategy.h"

@implementation PiratradioStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*piratrad.io/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){if(!window.player.track){window.player.playTrack(0); return;} window.player.isPaused ? window.player.playCurrent() : window.player.pauseCurrent(); })()";
}

-(NSString *) previous
{
    return @"(function(){if(!window.player.track){window.player.playTrack(0); return;} var wrap=function(x){if(x<0){x+=window.playlist.size();} return x;}; if(!window.player.shuffling){ window.player.trackNumber=wrap(window.player.trackNumber-2); window.player.nextTrack(); } else { var i=window.playlist.shuffledList.indexOf(window.player.trackNumber); window.player.trackNumber=window.playlist.shuffledList[wrap(i-2)]; window.player.nextTrack();}})()";
}

-(NSString *) next
{
    return @"(function(){if(!window.player.track){window.player.playTrack(0); return;} window.player.nextTrack();})()";
}

-(NSString *) pause
{
    return @"(function(){if(!window.player.track){return;} window.player.pauseCurrent();})()";
}

-(NSString *) displayName
{
    return @"Piratradio";
}

@end
