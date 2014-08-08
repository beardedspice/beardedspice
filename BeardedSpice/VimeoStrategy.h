//
//  VimeoStrategy.h
//  BeardedSpice
//
//  Created by Antoine Hanriat on 08/08/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//


#import "MediaStrategy.h"

@interface VimeoStrategy : MediaStrategy
{
    NSPredicate *predicate;
}
@end