//
//  BeatsMusicStrategy.h
//  BeardedSpice
//
//  Created by John Bruer on 1/27/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface BeatsMusicStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
