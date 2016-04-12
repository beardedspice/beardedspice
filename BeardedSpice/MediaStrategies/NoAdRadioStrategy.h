//
//  NoAdRadioStrategy.h
//  BeardedSpice
//


#import "MediaStrategy.h"

@interface NoAdRadioStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
