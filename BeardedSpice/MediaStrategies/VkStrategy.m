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
    return @"document.querySelector('#ac_play').click()";
}

-(NSString *) previous
{
    return @"document.querySelector('#ac_prev').click()";
}

-(NSString *) next
{
    return @"document.querySelector('#ac_next').click()";
}

-(NSString *) pause
{
    return @"document.querySelector('#ac_play').click()";
}

- (NSString *)favorite
{
    return @"document.querySelector('#ac_add').click()";
}

-(NSString *) displayName
{
    return @"VK";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    Track *track = [[Track alloc] init];
    [track setTrack:[tab executeJavascript:@"document.querySelector('span#ac_title').firstChild.nodeValue"]];
    [track setArtist:[tab executeJavascript:@"document.querySelector('span#ac_performer').firstChild.nodeValue"]];
    return track;
}

@end
