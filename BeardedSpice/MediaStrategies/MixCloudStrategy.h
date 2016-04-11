//
//  MixCloudStrategy.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 2/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface MixCloudStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
