//
//  MixCloudStrategy.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 2/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MixCloudStrategy.h"

@implementation MixCloudStrategy
-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*mixcloud.com*'"];
    }
    return self;
}
-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}
-(NSString *) toggle
{
    return @"document.querySelector('.player-control').click();";
}
-(NSString *) previous
{
    return @"";
}
-(NSString *) next
{
    return @"";
}
-(NSString *) pause
{
    // NOTE: this will fail if we are already paused, but that's fine.
    return @"document.querySelector('.pause-state').click()";
}
-(NSString *) displayName
{
    return @"MixCloud";
}
-(Track *) trackInfo:(id<Tab>)tab
{
    Track *track = [[Track alloc] init];
    [track setTrack:[tab executeJavascript:@"document.querySelector('.player-cloudcast-title').text"]];
    [track setArtist:[tab executeJavascript:@"document.querySelector('.player-cloudcast-author-link').text"]];
    return track;
}

-(NSString *) favorite
{
    return @"document.querySelector('.favorite').click()";
}
@end
