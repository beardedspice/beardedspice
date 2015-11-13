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

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{
    
    NSNumber *result = [tab executeJavascript:@"(function(){return ( (document.querySelector('#stopBtn:not(.ng-hide)') ? true : false));})();"];
    
    return [result boolValue];
}

-(NSString *) toggle
{
    return @"(function(){(document.querySelector('#playBtn:not(.ng-hide)')||document.querySelector('#stopBtn:not(.ng-hide)')).click()})()";
}

-(NSString *) pause
{
    return @"(function(){if(p=document.querySelector('#stopBtn:not(.ng-hide)')){p.click();}})()";
}

- (NSString *)favorite
{
    return @"(function(){document.querySelector('.row.card').querySelector('button').click()})()";
}

-(NSString *) displayName
{
    return @"SomaFM";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){var art=document.querySelector('.img-responsive').getAttribute('src'), card=document.querySelector('.row.card').querySelectorAll('div'); return {'track': card[1].firstChild.innerText, 'artist': card[2].firstChild.innerText, 'fav': card[3].firstChild.className.indexOf('btn-fav') > -1, 'art': art}})()"];

    Track *track = [[Track alloc] init];

    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.favorited = info[@"fav"];
    // no track album art available, this is the playlist art
    track.image = [self imageByUrlString:info[@"art"]];

    return track;
}

@end
