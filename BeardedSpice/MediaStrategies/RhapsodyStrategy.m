//
//  RhapsodyStrategy.m
//  BeardedSpice
//
//  Created by Aaron Pollack on 11/17/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RhapsodyStrategy.h"

@implementation RhapsodyStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*app.rhapsody.com*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(NSString *) toggle
{
    return @"(function(){ \
        if ($('.player-play-button .icon-pause2').length) { \
             $('.player-play-button .icon-pause2').click(); \
        } else { \
            $('.player-play-button .icon-play-button').click();\
        } \
    })()";
}

- (BOOL)isPlaying:(TabAdapter *)tab{
    NSNumber *result = [tab executeJavascript:@"(function(){return !!$('.player-play-button .icon-pause2').length;})()"];
    return [result boolValue];
}

-(NSString *) previous
{
    return @"(function(){$('.player-rewind-button').click();})()";
}

-(NSString *) next
{
    return @"(function(){$('.player-advance-button').click();})()";
}

-(NSString *) pause
{
    return @"(function(){$('.player-play-button .icon-pause2').click();})()";
}

-(NSString *) favorite
{
    return @"(function(){$('.favorite-button').click()})()";
}

-(NSString *) displayName
{
    return @"Rhapsody";
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    NSDictionary *info = [tab executeJavascript:@"(function(){function titleize(slug) {var words = slug.split('-');return words.map(function(word) {return word.charAt(0).toUpperCase() + word.substring(1).toLowerCase();}).join(' ');} return {'track': $('.player-track a')[0].innerText,'artist': ($('.player-artist a')[0].innerHTML).split('- ').slice(1).join('- ').trim(),'album': titleize($('.player-wrapper a').attr('href').split('album/')[1]), 'image': $('.player-album-thumbnail img')[0].src};})()"];
    
    Track *track = [[Track alloc] init];
    track.track = info[@"track"];
    track.artist = info[@"artist"];
    track.album = info[@"album"];
    track.image = [self imageByUrlString:info[@"image"]];
    
    return track;
}

@end


