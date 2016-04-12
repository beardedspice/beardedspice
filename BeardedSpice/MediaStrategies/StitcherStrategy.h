//
//  StitcherStrategy.h
//  BeardedSpice
//
//  Created by Christopher Williams on 3/24/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface StitcherStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
