//
//  TwitchStrategy.m
//  BeardedSpice
//
//  Created by Semyon Perepelitsa on 04.10.15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "TwitchStrategy.h"

@implementation TwitchStrategy

-(id)init {
    self = [super init];
    if (self) {
        predicate =
        [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*twitch.tv*'"];
    }
    return self;
}

-(NSString *)displayName {
    return @"Twitch";
}

- (BOOL)accepts:(TabAdapter *)tab {
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab {
    NSNumber *value =
        [tab executeJavascript: @"return !$('.player').data('paused')"];
    return [value boolValue];
}

- (NSString *)toggle {
    return @"$('.js-control-playpause-button').click()";
}

- (NSString *)pause {
    return @"$('.player[data-paused=\"false\"] .js-control-playpause-button').click()";
}
@end
