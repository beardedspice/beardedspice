//
//  CourseraStrategy.h
//  BeardedSpice
//
//  Created by Andrei Glingeanu on 7/29/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "MediaStrategy.h"

@interface CourseraStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
