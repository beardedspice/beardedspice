//
//  TuneInStrategy.m
//  BeardedSpice
//
//  Created by Cristian Yáñez on 14-01-15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TuneInStrategy.h"

@implementation TuneInStrategy
-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*tunein.com*'"];
    }
    return self;
}
-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}
-(NSString *) toggle
{
    return @"document.querySelector('.playbutton-cont').click();";
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
    return @"document.querySelector('.playbutton-cont').click()";
}
-(NSString *) displayName
{
    return @"TuneIn";
}
-(Track *) trackInfo:(id<Tab>)tab
{
    Track *track = [[Track alloc] init];
    [track setTrack:[tab executeJavascript:@"document.querySelector('.title').text"]];
    [track setArtist:[tab executeJavascript:@"document.querySelector('.line1').text"]];
    return track;
}

@end