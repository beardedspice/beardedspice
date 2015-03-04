//
//  TidalStrategy.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TidalHiFiStrategy.h"

@implementation TidalHiFiStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*listen.tidalhifi.com*'"];
    }
    return self;
}

-(BOOL) accepts:(id <Tab>)tab
{
    return [predicate evaluateWithObject:[tab URL]];
    
}

-(NSString *) toggle
{
    // check play/pause
    return @"(function(){var play=$('button.js-play'); if (play.css('display') == 'none') {$('button.js-pause').click();} else {play.click();} })();";
}

-(NSString *) previous
{
    return @"(function(){$('button.js-previous').click();})();";
}

-(NSString *) next
{
    return @"(function(){$('button.js-next').click();})();";
}

-(NSString *) pause
{
    return @"(function(){$('button.js-pause').click();})();";
}

- (NSString *)favorite
{
    return @"(function(){$('a.js-add-favorite').click();})();";
}

-(NSString *) displayName
{
    return @"TIDAL";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    Track *track = [[Track alloc] init];
    [track setTrack:[tab executeJavascript:@"document.querySelector('div.player__text>a[data-bind=title]').nodeValue"]];
    [track setArtist:[tab executeJavascript:@"document.querySelector('div.player__text>div[data-bind=artist]>a').nodeValue"]];
    return track;
}

@end
