//
//  ShufflerFmStrategy.h
//  BeardedSpice
//
//  Created by Breyten Ernsting on 1/16/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface ShufflerFmStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
