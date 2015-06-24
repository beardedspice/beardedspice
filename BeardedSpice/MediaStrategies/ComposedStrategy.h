//
//  ComposedStrategy.h
//  BeardedSpice
//
//  Created by Daniel Roseman on 23/06/2015.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "MediaStrategy.h"

@interface ComposedStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
