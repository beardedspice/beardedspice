//
//  EightTracksStrategy.m
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/15/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "EightTracksStrategy.h"

@implementation EightTracksStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*8tracks.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL) isPlaying:(TabAdapter *)tab
{
    NSString *script = @"(function(){"
    "    var pause = document.querySelector('#player_pause_button');"
    "    return pause !== null && pause.style.display !== 'none';"
    "})()";
    
    return [[tab executeJavascript:script] boolValue];
}

-(NSString *) toggle
{
    return @"(function(){"
    "    var play = document.querySelector('#player_play_button');"
    "    var pause = document.querySelector('#player_pause_button');"
    "    var overlay = document.querySelector('#play_overlay');"
    
    "    if (play !== null && play.style.display !== 'none') {"
    "        play.click();"
    "    } else if (pause !== null && pause.style.display !== 'none') {"
    "        pause.click();"
    "    } else if (overlay !== null) {"
    "        overlay.click();"
    "    }"
    "})();";
}

-(NSString *) previous
{
    return @"";
}

-(NSString *) next
{
    return @"(function(){"
    "    var skip = document.querySelector('#player_skip_button');"
    "    if (skip !== null) skip.click();"
    "})()";
}

-(NSString *) pause
{
    return @"(function(){"
    "    var pause = document.querySelector('#player_pause_button');"
    "    if (pause !== null) pause.click()"
    "})()";
}

- (NSString *)favorite
{
    // NOTE: This favorites the current track, not the current mix
    return @"(function(){"
    "    var fav = document.querySelector('#now_playing a.fav');"
    "    if (fav !== null) fav.click()"
    "})()";
}

-(NSString *) displayName
{
    return @"8tracks";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSString *script = @"(function(){"
    "    var nowPlaying  = document.querySelector('#now_playing');"
    "    var titleArtist = nowPlaying.querySelector('.title_artist');"
    
    "    var title  = titleArtist.querySelector('.t').textContent;"
    "    var artist = titleArtist.querySelector('.a').textContent;"
    
    "    var album = nowPlaying.querySelector('.track_details .track_metadata .album .detail').textContent;"
    
    "    var fav = nowPlaying.querySelector('a.fav').classList.contains('active');"

    "    var img = document.querySelector('#mix_player_details a.thumb img').src;"
    
    "    return {"
    "        artist: artist,"
    "        album:  album,"
    "        title:  title,"
    "        fav:    fav,"
    "        img:    img"
    "    };"
    "})()";
    
    NSDictionary *song = [tab executeJavascript:script];

    Track *track    = [[Track alloc] init];
    track.track     = song[@"title"];
    track.album     = song[@"album"];
    track.artist    = song[@"artist"];
    track.favorited = song[@"fav"];
    
    NSString *imageURLString = song[@"img"];
    if (imageURLString) {
        track.image = [self imageByUrlString:imageURLString];
    }
    
    return track;
}

@end
