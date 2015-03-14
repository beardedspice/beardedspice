//
//  NetflixStrategy.h
//  BeardedSpice
//
//  Created by Martijn Engler on 3/6/15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//


#import "MediaStrategy.h"

@interface NetflixStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
