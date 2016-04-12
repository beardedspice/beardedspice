//
//  WatchaPlayStrategy.h
//  BeardedSpice
//
//  Created by KimJongMin on 2016. 3. 1..
//  Copyright © 2016년 BeardedSpice. All rights reserved.
//

#import "MediaStrategy.h"

@interface WatchaPlayStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
