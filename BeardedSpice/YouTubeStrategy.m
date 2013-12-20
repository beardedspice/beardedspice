//
//  YouTubeStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YouTubeStrategy.h"

@implementation YouTubeStrategy

-(BOOL) accepts:(id <Tab>)tab
{
    return [[tab URL] isCaseInsensitiveLike:@"*youtube.com/watch*"];
}

-(NSString *) toggle
{
    return @"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){var n=t[e];if(n.getPlayerState()==1){n.pauseVideo()}else{n.playVideo()}}})()";
}

-(NSString *) previous
{
    return @"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){t[e].previousVideo()}})()";
}

-(NSString *) next
{
    return @"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){t[e].nextVideo()}})()";
}

-(NSString *) pause
{
    return @"(function(){var e=0,t=document.querySelectorAll('#movie_player');for(e=0;e<t.length;e++){var n=t[e];n.pauseVideo()}})()";    
}

@end
