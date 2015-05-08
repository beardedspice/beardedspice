//
//  VkStrategy.m
//  BeardedSpice
//
//  Created by Anton Mihailov on 17/06/14.
//  Copyright (c) 2014 Anton Mihailov. All rights reserved.
//

#import "VkStrategy.h"

@implementation VkStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*vk.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *value = [tab executeJavascript:@"!!document.querySelector('#ac_play.playing, #gp_play.playing');"];
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(w){\
        var el = document.querySelector('#ac_play, #gp_play');\
        if (el) { el.click(); return; }\
        w.Pads.show('mus', null);\
        var pollPlayerInterval = setInterval(\
        (function(w){\
            return function(){\
                var el = document.querySelector('#pd_play');\
                if (!el) { return; }\
                clearInterval(pollPlayerInterval);\
                el.click();\
                w.Pads.hide('mus', null);\
            }\
        })(w), 10);\
    })(window)";
}

-(NSString *) previous
{
    return @"(function(w){\
        var el = document.querySelector('#ac_prev');\
        if (el) { el.click(); return; }\
        w.Pads.show('mus', null);\
        var pollPlayerInterval = setInterval(\
        (function(w){\
            return function(){\
                var el = document.querySelector('#pd_prev');\
                if (!el) { return; }\
                clearInterval(pollPlayerInterval);\
                el.click();\
                w.Pads.hide('mus', null);\
            }\
        })(w), 10);\
    })(window)";
}

-(NSString *) next
{
    return @"(function(w){\
        var el = document.querySelector('#ac_next');\
        if (el) { el.click(); return; }\
        w.Pads.show('mus', null);\
        var pollPlayerInterval = setInterval(\
        (function(w){\
            return function(){\
                var el = document.querySelector('#pd_next');\
                if (!el) { return; }\
                clearInterval(pollPlayerInterval);\
                el.click();\
                w.Pads.hide('mus', null);\
            }\
        })(w), 10);\
    })(window)";
}

-(NSString *) pause
{
    return @"(function(w){\
        var el = document.querySelector('#ac_play.playing, #gp_play.playing');\
        if (el) { el.click(); return; }\
        w.Pads.show('mus', null);\
        var pollPlayerInterval = setInterval(\
        (function(w){\
            return function(){\
                var el = document.querySelector('#pd_play.playing');\
                if (!el) { return; }\
                clearInterval(pollPlayerInterval);\
                el.click();\
                w.Pads.hide('mus', null);\
            }\
        })(w), 10);\
        setTimeout(function(){clearInterval(pollPlayerInterval);}, 1000);\
    })(window)";
}

- (NSString *)favorite
{
    return @"(function(w){\
        var el = document.querySelector('#ac_add');\
        if (el) { el.click(); return; }\
        w.Pads.show('mus', null);\
        var pollPlayerInterval = setInterval(\
        (function(w){\
            return function(){\
                var el = document.querySelector('#pd_add');\
                if (!el) { return; }\
                clearInterval(pollPlayerInterval);\
                el.click();\
                w.Pads.hide('mus', null);\
            }\
        })(w), 10);\
    })(window)";
}

-(NSString *) displayName
{
    return @"VK";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab
        executeJavascript:@"(function(w){\
                                var titleEl = document.querySelector('span#ac_title, #gp_title'),\
                                    artistEl = document.querySelector('span#ac_performer, #gp_performer');\
                                if (! titleEl || ! artistEl) {\
                                    w.Pads.show('mus', null);\
                                    titleEl = document.querySelector('span#pd_title'),\
                                    artistEl = document.querySelector('span#pd_performer');\
                                    w.Pads.hide('mus', null);\
                                }\
                                if (!(titleEl && artistEl)) { return {}; }\
                                return {'title': titleEl.firstChild.nodeValue, 'artist': artistEl.firstChild.nodeValue};\
                            })(window)"];
    Track *track = [Track new];
    [track setTrack:info[@"title"]];
    [track setArtist:info[@"artist"]];

    return track;
}

@end
