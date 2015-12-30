#import "TwitchMediaStrategy.h"

@implementation TwitchMediaStrategy

-(id) init
{
    self = [super init];
    if (self) {
        predicate = [NSPredicate predicateWithFormat:@"SELF LIKE[c] '*twitch.tv/*'"];
    }
    return self;
}

-(BOOL) accepts:(TabAdapter *)tab
{
    return [predicate evaluateWithObject:[tab URL]];
}

-(BOOL)isPlaying:(TabAdapter *)tab
{
    NSNumber *val = [tab executeJavascript:@"(function(){ return $('.player[data-paused=\"false\"]').length })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){ $('.js-control-playpause-button').click() })()";
}

-(NSString *) pause
{
    return @"(function(){ $('.player[data-paused=\"false\"] .js-control-playpause-button').click() })()";
}

-(NSString *) displayName
{
    return @"twitch.tv";
}

@end
