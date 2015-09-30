//
//  PlexWebStrategy.h
//  BeardedSpice
//
//  Created by Ryan Sullivan on 8/20/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "MediaStrategy.h"

@interface PlexWebStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
