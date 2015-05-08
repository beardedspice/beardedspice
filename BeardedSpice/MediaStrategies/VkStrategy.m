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

-(NSString *) toggle
{
    return @"(function(p){\
        var el = document.querySelector('#ac_play');\
        if (!el) {\
            p.show('mus', null);\
            el = document.querySelector('#pd_play');\
        }\
        el.click();\
        p.hide('mus', null);\
    })(Pads)";
}

-(NSString *) previous
{
    return @"(function(p){\
        var el = document.querySelector('#ac_prev');\
        if (!el) {\
            p.show('mus', null);\
            el = document.querySelector('#pd_prev');\
        }\
        el.click();\
        p.hide('mus', null);\
    })(Pads)";
}

-(NSString *) next
{
    return @"(function(p){\
        var el = document.querySelector('#ac_next');\
        if (!el) {\
            p.show('mus', null);\
            el = document.querySelector('#pd_next');\
        }\
        el.click();\
        p.hide('mus', null);\
    })(Pads)";
}

-(NSString *) pause
{
    return @"(function(p){\
        var el = document.querySelector('#ac_play.playing');\
        if (!el) {\
            p.show('mus', null);\
            el = document.querySelector('#pd_play.playing');\
        }\
        el && el.click();\
        p.hide('mus', null)\
    })(Pads)";
}

- (NSString *)favorite
{
    return @"(function(p){\
        var el = document.querySelector('#ac_add');\
        if (el) {\
            p.show('mus', null);\
            document.querySelector('#pd_add');\
        }\
        el.click();\
        p.hide('mus', null);\
    })(Pads)";
}

-(NSString *) displayName
{
    return @"VK";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    [track setTrack:[tab executeJavascript:@"(function(p){p.show('mus', null); var s = document.querySelector('span#ac_title, #gp_title').firstChild.nodeValue; p.hide('mus', null); return s})(Pads)"]];
    [track setArtist:[tab executeJavascript:@"(function(p){p.show('mus', null); var s = document.querySelector('span#ac_performer, #gp_performer').firstChild.nodeValue; p.hide('mus', null); return s})(Pads)"]];
    return track;
}

@end
