//
//  TwentyTwoTracksStrategy.h
//  BeardedSpice
//
//  Created by Jan Pochyla on 08/26/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface TwentyTwoTracksStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
