//
//  SomaFmStrategy.m
//  BeardedSpice
//
//  Created by Max Borghino on 1/28/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SomaFmStrategy.h"

@implementation SomaFmStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*somafm.com/player/*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){(document.querySelector('#playBtn:not(.ng-hide)')||document.querySelector('#pauseBtn:not(.ng-hide)')).click()})()";
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
    return @"(function(){if(p=document.querySelector('#pauseBtn:not(.ng-hide)')){p.click();}})()";
}

- (NSString *)favorite
{
    return @"(function(){document.querySelector('.row.card').querySelector('button').click()})()";
}

-(NSString *) displayName
{
    return @"SomaFM";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){var card=document.querySelector('.row.card').querySelectorAll('div'); return {'track': card[1].firstChild.innerText, 'artist': card[2].firstChild.innerText, 'fav': card[3].firstChild.className.indexOf('btn-fav') > -1}})()"];

    Track *track = [[Track alloc] init];

    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.favorited = info[@"fav"];

    return track;
}

@end
