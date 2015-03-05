//
//  TidalHiFiStrategy.m
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
    return @"(function(){var play=$('button.js-play'); if (play.css('display') === 'none') {$('button.js-pause').click();} else {play.click();} })();";
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
    return @"(function(){var fav=$('a.js-add-favorite'); if (fav.length){ fav.click();} else {$('a.js-remove-favorite').click();}})()";
}

-(NSString *) displayName
{
    return @"TIDAL";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    @autoreleasepool {
        
        NSDictionary *songData = [tab executeJavascript:@"(function(){ return {'track':$('div.player__text>a[data-bind=title]').text(), 'artist':$('div.player__text>div[data-bind=artist]>a').text(), 'imageUrl':$('div.player div.image--player img[data-bind-src=\"imageUrl\"]').attr('src') }; })()"];
        Track *track = [[Track alloc] init];
        
        track.track = songData[@"track"];
        track.artist = songData[@"artist"];
        
        NSString *urlString = songData[@"imageUrl"];
        if (urlString) {
            
            if ([urlString isEqualToString:_lastImageUrlString]) {
                
                track.image = _lastImage;
            }
            else{
                
                _lastImageUrlString = urlString;
                NSURL *url = [NSURL URLWithString:urlString];
                if (url) {
                    track.image = _lastImage = [[NSImage alloc] initWithContentsOfURL:url];
                }
            }
        }
        return track;
    }
}

@end
