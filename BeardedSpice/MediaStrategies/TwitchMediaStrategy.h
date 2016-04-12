#import "MediaStrategy.h"

@interface TwitchMediaStrategy : MediaStrategy <MediaStrategyProtocol> {
    
    NSPredicate *predicate;
    
}

@end
