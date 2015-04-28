//
//  OdnoklassnikiStrategy.m
//  BeardedSpice
//
//  Created by Alexander Chuprin on 2/16/2015.
//  Copyright (c) 2015 Alexander Chuprin. All rights reserved.
//

#import "OdnoklassnikiStrategy.h"

@implementation OdnoklassnikiStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*ok.ru*' OR SELF LIKE[c] '*odnoklassniki.ru*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){if (odklMusic.playingTrack() == \"\") {if (window['__getMusicFlash']) {__getMusicFlash().lcResume()} else {odklMusic.openAndLaunchMusicPlaying();}} else {__getMusicFlash().lcPause();}})()";
}

-(NSString *) previous
{
    return @"__getMusicFlash().lcPrev()";
}

-(NSString *) next
{
    return @"__getMusicFlash().lcNext()";
}

-(NSString *) pause
{
    return @"__getMusicFlash().lcPause();";
}

-(NSString *) displayName
{
    return @"Odnoklassniki";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    [track setTrack:[tab executeJavascript:@"document.querySelector('#mmpcw .mus_player_song').firstChild.nodeValue"]];
    [track setArtist:[tab executeJavascript:@"document.querySelector('#mmpcw .mus_player_artist').firstChild.nodeValue"]];
    return track;
}

@end
