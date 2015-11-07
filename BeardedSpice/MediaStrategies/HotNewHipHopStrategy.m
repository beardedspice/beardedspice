//
//  HotNewHipHopStrategy.m
//  BeardedSpice
//
//  Created by Ivan Doroshenko on 11/7/15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "HotNewHipHopStrategy.h"

@implementation HotNewHipHopStrategy

- (instancetype)init {
    self = [super init];
    
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*hotnewhiphop.com*'"];
    }
    
    return self;
    
}
-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *value = [tab executeJavascript:@"$(\"#jquery_jplayer_playlist\").data().jPlayer.status.paused;"];
    return ![value boolValue];
}

-(NSString *) toggle
{
    return @"(function(){\
    if ($(\"#jquery_jplayer_playlist\").data().jPlayer.status.paused) { \
    $(\"#jquery_jplayer_playlist\").jPlayer(\"play\");\
    } else { \
    $(\"#jquery_jplayer_playlist\").jPlayer(\"pause\");\
    } \
    })()";
}


-(NSString *) pause
{
    return @"(function(){$(\"#jquery_jplayer_playlist\").jPlayer(\"pause\");})()";
}

- (NSString *)next {
    return @"(function(){$(\".jp-next\").click();})()";
}

- (NSString *)previous {
    return @"(function(){$(\".jp-previous\").click();})()";
}

-(NSString *) displayName
{
    return @"HotNewHipHop";
}

@end
