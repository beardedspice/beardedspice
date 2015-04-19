//
//  VkStrategy.h
//  BeardedSpice
//
//  Created by Anton Mihailov on 1/15/2014.
//  Copyright (c) 2014 Anton Mihailov. All rights reserved.
//

#import "MediaStrategy.h"

@interface VkStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end