//
//  SpotifyBetaStrategy.m
//  BeardedSpice
//
//  Created by Azorr on 07/23/2015.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SpotifyBetaStrategy.h"

@implementation SpotifyBetaStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*player.spotify.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelectorAll('#main')[0].contentWindow.document.querySelectorAll('#play')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelectorAll('#main')[0].contentWindow.document.querySelectorAll('#previous')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelectorAll('#main')[0].contentWindow.document.querySelectorAll('#next')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){var e=document.querySelectorAll('#main')[0].contentWindow.document.querySelectorAll('#play')[0];if(e.classList.contains('playing')){e.click()}})()";
}

-(NSString *) displayName
{
    return @"Spotify Beta";
}

@end
