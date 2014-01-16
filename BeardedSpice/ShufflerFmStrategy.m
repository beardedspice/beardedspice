//
//  ShufflerFmStrategy.m
//  BeardedSpice
//
//  Created by Breyten Ernsting on 1/16/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ShufflerFmStrategy.h"

@implementation ShufflerFmStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*shuffler.fm/tracks*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){var ap=window.SHUFFLER.audioPlayer;if(ap.playing()){ap.pause();}else{ap.play();}})()";
}

-(NSString *) previous
{
    return @"(function(){SHUFFLER.playerController.onPlayerUiButtonPrevHandler();})()";
}

-(NSString *) next
{
    return @"(function(){window.SHUFFLER.playerController.onAudioPlayerPlaybackEndHandler();})()";
}

-(NSString *) pause
{
    return @"(function(){window.SHUFFLER.audioPlayer.pause();})()";
}

-(NSString *) displayName
{
    return @"Shuffler.fm";
}

@end
