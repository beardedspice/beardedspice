//
//  OvercastStrategy.h
//  BeardedSpice
//
//  Created by Alan Clark on 8/6/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//


#import "MediaStrategy.h"

@interface OvercastStrategy : MediaStrategy
{
    NSPredicate *predicate;
}
@end