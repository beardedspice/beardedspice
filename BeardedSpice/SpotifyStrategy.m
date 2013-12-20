//
//  SpotifyStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/19/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SpotifyStrategy.h"

@implementation SpotifyStrategy

-(BOOL) accepts:(id <Tab>)tab
{
    return [[tab URL] isCaseInsensitiveLike:@"*play.spotify.com*"];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#play-pause')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#previous')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#next')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){var e=document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#play-pause')[0];if(e.classList.contains('playing')){e.click()}})()";
}

-(NSString *) displayName
{
    return @"Spotify";
}


@end
