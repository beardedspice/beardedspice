//
//  DigitallyImportedStrategy.m
//  BeardedSpice
//
//  Created by Dennis Lysenko on 4/4/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "DigitallyImportedStrategy.h"

@implementation DigitallyImportedStrategy

- (id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*di.fm*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab{
    NSNumber *value = [tab executeJavascript:@"(function(){ return ($('#webplayer-region .controls .ico.icon-pause').get(0) ? true : false);})()"];
    
    return [value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('div.controls a')[0].click()})()";
}

-(NSString *) pause
{
    return @"(function(){var pause = document.querySelectorAll('div.controls a')[0];if(pause.classList.contains('icon-pause')){pause.click();}})()";
}

-(NSString *) displayName
{
    return @"Digitally Imported";
}

- (NSString *)favorite{
    
    return @"(function(){$('.vote-btn.up').click();})()";
}

- (Track *)trackInfo:(TabAdapter *)tab {

    NSDictionary *dict = [tab
        executeJavascript:@"(function(){return {"
        @"'rawArtistName': $('.artist-name').text()"
        @", 'fullTrackName': $('.track-name').text()"
        @", 'favorited': ($('.icon-thumbs-up-filled').get(0) ? true : false)"
        @", 'imageUrl': $('#webplayer-region .track-region .artwork img').attr('src')"
        @"}})()"];

    NSString *artistName = dict[@"rawArtistName"];
    NSUInteger length = artistName.length;
    if (length > 3) {
        // strip off trailing " - "
        artistName = [artistName substringToIndex:(length - 3)];
    }

    NSString *trackName = [dict[@"fullTrackName"] stringByReplacingOccurrencesOfString:dict[@"rawArtistName"] withString:@""];

    Track *track = [Track new];

    track.track = [trackName
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]]; // only grab the
                                                      // actual song title
    track.artist = artistName;
    track.favorited = dict[@"favorited"];

    NSString *imageUrl = dict[@"imageUrl"];
    if (imageUrl) {
        NSRange range = [imageUrl rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            imageUrl =
                [[imageUrl substringToIndex:(range.location + range.length)]
                    stringByAppendingString:@"?size=128x128"];
        }
        track.image = [self imageByUrlString:imageUrl];
    }

    return track;
}

@end
