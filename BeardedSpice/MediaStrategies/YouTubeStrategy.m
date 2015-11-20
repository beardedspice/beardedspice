//
//  YouTubeStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "YouTubeStrategy.h"

@implementation YouTubeStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*youtube.com/watch*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){ document.querySelector('#movie_player .ytp-play-button').click(); })()";
}

-(NSString *) previous
{
    return @"(function(){ document.querySelector('#movie_player .ytp-prev-button').click(); })()";
}

-(NSString *) next
{
    return @"(function(){ document.querySelector('#movie_player .ytp-next-button').click(); })()";
}

-(NSString *) pause
{
    return @"(function(){ document.querySelector('#movie_player video').pause(); })()";
}

-(NSString *) displayName
{
    return @"YouTube";
}

@end
