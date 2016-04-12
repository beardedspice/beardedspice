//
//  DailymotionStrategy.h
//  BeardedSpice
//
//  Created by Alexandre Daussy on 03/19/16.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface DailymotionStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
