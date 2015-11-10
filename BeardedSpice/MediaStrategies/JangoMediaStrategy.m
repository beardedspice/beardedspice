//
//  JangoMediaStrategy.m
//  BeardedSpice
//
//  Created by Stanislav Sidelnikov on 09/11/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "JangoMediaStrategy.h"

@implementation JangoMediaStrategy

- (id)init {
    self = [super init];
    if (self) {
        predicate =
        [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*jango.com*'"];
    }
    return self;
}

- (BOOL)accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

- (BOOL)isPlaying:(TabAdapter *)tab {
    NSNumber *value = [tab executeJavascript:@"(function(){return "
                       @"(document.querySelector('#btn-playpause.pause') != null);}())"];
    
    return [value boolValue];
}

- (NSString *)toggle {
    return @"(function(){document.querySelector('a#btn-playpause').click()})()";
}

- (NSString *)next {
    return @"(function(){document.querySelector('a#btn-ff').click()})()";
}

- (NSString *)pause {
    return @"(function(){\
        var e=document.querySelector('a#btn-playpause.pause');\
        if(e!=null){\
            e.click();\
        }\
    })()";
}

- (NSString *)displayName {
    return @"Jango";
}

- (Track *)trackInfo:(TabAdapter *)tab {
    
    NSDictionary *info = [tab
                          executeJavascript:@"(function(){\
                            return {\
                                'track': $('#current-song')[0].innerText,\
                                'artist': $('#player_current_artist a')[0].innerText,\
                                'favorited': false,\
                                'albumArt': $('#player_main_pic_img').attr('src')\
                            };\
                          })()"];
    
    Track *track = [Track new];
    
    [track setValuesForKeysWithDictionary:info];
    track.image = [self imageByUrlString:info[@"albumArt"]];
    
    return track;
}

@end
