//
//  SaavnStrategy.h
//  BeardedSpice
//
//  Created by Yash Aggarwal on 1/6/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface SaavnStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
