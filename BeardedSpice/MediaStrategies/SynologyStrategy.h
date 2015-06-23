//
//  SynologyStrategy.h
//  BeardedSpice
//
//  Created by Stephan van Diepen on 16/01/2014.
//  Copyright (c) 2013 Stephan van Diepen. All rights reserved.
//

#import "MediaStrategy.h"

@interface SynologyStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
