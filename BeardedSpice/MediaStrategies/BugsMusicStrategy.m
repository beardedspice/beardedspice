//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by Jinseop Kim on 01/03/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "BugsMusicStrategy.h"

@implementation BugsMusicStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*music.bugs.co.kr/newPlayer*'"];
    }
    return self;
}

-(NSString *) displayName
{
    return @"BugsMusic";
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return bugs.player.isPlayingTrack; })()"];
    return [val boolValue];
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];

    NSDictionary *metadata = [tab executeJavascript:@"(function(){ return {"
                              @"  image:  document.querySelector('.thumbnail > img').getAttribute('src'),"
                              @"  track:  bugs.player.getCurrentTrackInfo().track_title,"
                              @"  artist: bugs.player.getCurrentTrackInfo().artist_nm,"
                              @"}})()"];
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    return track;
}

-(NSString *) toggle
{
    return @"(function(){ bugs.player.playButtonHandler().call(); })()";
}

-(NSString *) previous
{
    return @"(function(){ bugs.player.prevButtonHandler().call(); })()";
}

-(NSString *) next
{
    return @"(function(){ bugs.player.nextButtonHandler().call(); })()";
}

-(NSString *) pause
{
    return @"(function(){ if (bugs.player.isPlayingTrack) bugs.player.playButtonHandler().call(); })()";
}

-(NSString *) favorite
{
    return @"(function (){"
           @"  if (document.querySelector('.btnLikeTrackCancel').style.display == \"none\") "
           @"    bugs.player.likeButtonHandler().call();"
           @"    bugs.player.likeCancelButtonHandler().call(); "
           @"  })()";
}

@end
