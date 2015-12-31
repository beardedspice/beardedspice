#import "TwitchMediaStrategy.h"

#define GET_DOCUMENT_MACRO @"var doc = document; var frame = $('iframe[src^=\\'http://player.twitch.tv/?channel=\\']').get(0); if (frame) {doc = frame.contentDocument || frame.contentWindow.document; } "

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
    NSNumber *val = [tab executeJavascript:@"(function(){" GET_DOCUMENT_MACRO @"return (doc.querySelector('.player[data-paused=\"false\"]') != null); })()"];
    return [val boolValue];
}

-(NSString *) toggle
{
    return @"(function(){" GET_DOCUMENT_MACRO @"doc.querySelector('.js-control-playpause-button').click() })()";
}

-(NSString *) pause
{
    return @"(function(){" GET_DOCUMENT_MACRO @"doc.querySelector('.player[data-paused=\"false\"] .js-control-playpause-button').click() })()";
}

-(NSString *) displayName
{
    return @"twitch.tv";
}

@end
