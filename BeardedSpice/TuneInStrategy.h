//
//  TuneInStrategy.h
//  BeardedSpice
//
//  Created by Cristian Yáñez on 14-01-15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//


#import "MediaStrategy.h"

@interface TuneInStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
