//
//  FocusAtWillStrategy.h
//  BeardedSpice
//
//  Created by Ken Mickles on 1/15/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface FocusAtWillStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
