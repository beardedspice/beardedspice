//
//  MusicUnlimitedStrategy.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 2/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MusicUnlimitedStrategy.h"

@implementation MusicUnlimitedStrategy
-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*music.sonyentertainmentnetwork.com*'"];
    }
    return self;
}
-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}
-(NSString *) toggle
{
    return @"document.querySelector('#PlayerPlayPause').click()";
}
-(NSString *) previous
{
    return @"document.querySelector('#PlayerPrevious').click()";
}
-(NSString *) next
{
    return @"document.querySelector('#PlayerNext').click()";
}
-(NSString *) pause
{
    // this site is pretty gnarly. Not implementing this for now.
    return @"";
}
-(NSString *) displayName
{
    return @"MusicUnlimited";
}
-(Track *) trackInfo:(TabAdapter *)tab
{
    // this site is pretty gnarly. Not implementing this for now.
    return NULL;
}

-(NSString *) favorite
{
    return @"document.querySelector('#PlayerLike').click()";
}

@end
