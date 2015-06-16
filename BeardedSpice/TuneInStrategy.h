//
//  TuneInStrategy.h
//  BeardedSpice
//
//  Created by Michael Alden on 4/17/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface TuneInStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
