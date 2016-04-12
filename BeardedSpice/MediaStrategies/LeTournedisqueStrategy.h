//
//  LeTournedisqueStrategy.h
//  BeardedSpice
//
//  Created by Jonas Friedmann on 18.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface LeTournedisqueStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
