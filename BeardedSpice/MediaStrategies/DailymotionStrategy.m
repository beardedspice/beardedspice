//
//  DailymotionStrategy.m
//  BeardedSpice
//
//  Created by Alexandre Daussy on 03/19/16
//
//  Code explanations : If video is played as a single video, we can access the player directly
//  But if the video is part of a playlist, the player is inside an iframe
//  and we need to access first the iframe's document and then the player
//
//  README : Please note that you have to use HTML5 version of Dailymotion.
//  Since Chrome makes you use its integrated version of flash even tho you have disabled
//  it in your system's preferences, I would recommend using Safari or being logged in on Dailymotion in Chrome.
//  Then, in your preferences, you should enable monetization of your videos, in order to have
//  customization of video player which means, inter alia, HTML5.
//
//  No control on the original website to choose next or previous video in a playlist, so not available here neither
//
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//


#import "DailymotionStrategy.h"

@implementation DailymotionStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*dailymotion.com*'"];
    }
    return self;
}


-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}


-(BOOL)isPlaying:(TabAdapter *)tab
{
    BOOL isPlaylist = [self isPlaylist:tab];
    NSNumber *val;
    
    val = (!isPlaylist)
            ? [tab executeJavascript:@"(function(){ !document.querySelector('#player').paused; })()"]
            : [tab executeJavascript:@"(function(){ !document.querySelector('#playerv5-iframe').contentWindow.document.querySelector('#player').paused; })()"];
    
   
    return [val boolValue];
    
}

-(BOOL)isPlaylist:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return !(document.querySelector('#playerv5-iframe') == null); })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ "
                @"document.querySelector('#playerv5-iframe') == null"
                @"? document.querySelector('#player button.dmp_PlaybackButton').click()"
                @": document.querySelector('#playerv5-iframe').contentWindow.document.querySelector('#player button.dmp_PlaybackButton').click();"
            @"})()";
    
}

-(NSString *) paused
{
    return @"(function(){ "
                @"document.querySelector('#playerv5-iframe') == null"
                @"? document.querySelector('#player').pause"
                @": document.querySelector('#playerv5-iframe').contentWindow.document.querySelector('#player').pause;"
            @"})()";
}

-(NSString *) displayName
{
    return @"Dailymotion";
}


-(NSString *) favorite
{
    return @"(function() {\
                if (document.querySelector('#playerv5-iframe') == null) {\
                    document.querySelector('button.btn_v2.pull-end.mrg-end-md.js-like.btn_v2--like').click();\
                } else {\
                    if (document.querySelector('a[title=Like]') == null)\
                        document.querySelector('a[title=Unlike]').click();\
                    else\
                        document.querySelector('a[title=Like]').click();\
                }\
            })()";
}

-(Track *)trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    BOOL playlist =  [self isPlaylist:tab];
    NSDictionary *metadata;
    
    if (!playlist) {
        metadata = [tab executeJavascript:@"(function(){ return {"
                    @"  image:  document.querySelector('link[rel=thumbnail]').getAttribute('href'),"
                    @"  track:  document.querySelector('meta[itemprop=name]').getAttribute('content'),"
                    @"  artist: document.querySelector('div[itemprop=author] meta[itemprop=name]').getAttribute('content'),"
                    @"}})()"];
    } else {
        metadata = [tab executeJavascript:@"(function() { return {"
                    @"  image:  document.querySelector('img.preview').getAttribute('src'),"
                    @"  track:  document.querySelector('#playerv5-iframe').contentWindow.document.querySelector('div[role=contentinfo] .dmp_VideoInfo-title a').innerText,"
                    @"  artist: document.querySelector('#playerv5-iframe').contentWindow.document.querySelector('div[role=contentinfo] .dmp_VideoInfo-owner a').innerText,"
                    @"}})()"];
    }
    
    track.track = [metadata valueForKey:@"track"];
    track.image = [self imageByUrlString:[metadata valueForKey:@"image"]];
    track.artist = [metadata valueForKey:@"artist"];
    
    
    return track;
}



@end
