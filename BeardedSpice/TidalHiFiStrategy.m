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
    return @"(function(){var player=require('media/playbackController'); if (player.isPlaying()) {player.pause();} else {player.resume();} })();";
}

-(NSString *) previous
{
    return @"(function(){require('media/playbackController').playPrevious();})();";
}

-(NSString *) next
{
    return @"(function(){require('media/playbackController').playNext();})();";
}

-(NSString *) pause
{
    return @"(function(){require('media/playbackController').pause();})();";
}

- (NSString *)favorite
{
    return @"(function(){$('a.js-favorite').click();})()";
}

-(NSString *) displayName
{
    return @"TIDAL";
}

-(Track *) trackInfo:(id<Tab>)tab
{
    @autoreleasepool {
        
        NSDictionary *songData = [tab executeJavascript:@"(function(){ var obj = require('media/playbackController').getCurrentTrack().attributes; return {'track':obj.title, 'artist':obj.artist.name, 'album':obj.album.title, 'imageUrl':$('div.player div.image--player img[data-bind-src=\"imageUrl\"]').attr('src'), 'favorited':(obj.favoriteDate !== undefined)}; })()"];
        Track *track = [[Track alloc] init];
        
        track.track = songData[@"track"];
        track.artist = songData[@"artist"];
        track.album = songData[@"album"];
        track.favorited = songData[@"favorited"];
        
        track.image = [self imageByUrlString:songData[@"imageUrl"]];
        return track;
    }
}

@end
