//
//  AudioMackStrategy.m
//  BeardedSpice
//
//  Created by Sean Coker on 12/11/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AudioMackStrategy.h"

@implementation AudioMackStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*audiomack.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){var player = document.getElementById('listplayer');var play_button = document.getElementById('play-button');if (player && player.clientHeight) {play_button.click();return;}var feed_buttons = document.querySelectorAll('.feed a.play');if (feed_buttons.length) {feed_buttons[0].click();return;}if (play_button) {play_button.click();} })()";
}

-(NSString *) previous
{
    return @"(function(){var player = document.getElementById('listplayer');if (player && player.clientHeight) {var prev_button = player.querySelector('.prev-track');prev_button.click();return;}var feed_buttons = document.querySelectorAll('.feed a.play');if (feed_buttons.length) {feed_buttons[0].click();return;}})()";
}

-(NSString *) next
{
    return @"(function(){var player = document.getElementById('listplayer');if (player && player.clientHeight) {var next_button = player.querySelector('.next-track');next_button.click();return;}var feed_buttons = document.querySelectorAll('.feed a.play');if (feed_buttons.length) {feed_buttons[0].click();return;}})()";
}

-(NSString *) pause
{
    return @"(function(){var play_button = document.getElementById('play-button');if (play_button.className.indexOf('pause') > 1) {play_button.click();}})()";
}

-(NSString *) displayName
{
    return @"AudioMack";
}

//-(Track *) trackInfo:(TabAdapter *)tab
//{
//    Track *track = [[Track alloc] init];
//    [track setTrack:[tab executeJavascript:@"document.querySelector('span#ac_title').firstChild.nodeValue"]];
//    [track setArtist:[tab executeJavascript:@"document.querySelector('span#ac_performer').firstChild.nodeValue"]];
//    return track;
//}

@end