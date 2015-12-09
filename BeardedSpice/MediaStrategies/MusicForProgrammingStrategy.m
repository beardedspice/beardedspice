//
//  MusicForProgrammingStrategy.m
//  BeardedSpice
//
//  Created by Max Borghino on 12/01/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

// strategy/site notes
// - favorite, not implemented on this site
// - single sets are long, so next/prev implements the site's forward/rewind on the set
// - track info consists only of the set number and name, no artist or artwork

#import "MusicForProgrammingStrategy.h"

@implementation MusicForProgrammingStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*musicforprogramming.net/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{

    NSNumber *result = [tab executeJavascript:@"(function(){return ( (document.querySelector('.playerControls #player_playpause').innerText === '[PAUSE]'));})();"];

    return [result boolValue];
}

-(NSString *) toggle
{
    return @"(function(){document.querySelector('.playerControls #player_playpause').click();})()";
}

- (NSString *)previous {
    return @"(function(){document.querySelector('.playerControls #player_rew').click()})()";
}

- (NSString *)next {
    return @"(function(){document.querySelector('.playerControls #player_ffw').click()})()";
}

-(NSString *) pause
{
    // could click 'stop' but the experience is better if we click 'playpause' as it does not lose position
    return @"(function(){var playPause=document.querySelector('.playerControls #player_playpause'); if(playPause && playPause.innerText === '[PAUSE]'){ playPause.click(); }})()";
}

-(NSString *) displayName
{
    return @"Music For Programming";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){var track=document.querySelector('.selected');  return {'track': track ? track.innerText : ''}})()"];

    Track *track = [[Track alloc] init];
    track.track = info[@"track"];
    // there is no track album art, artist, fav

    return track;
}

@end
