//
//  EightTracksStrategy.h
//  BeardedSpice
//
//  Created by Jayson Rhynas on 1/15/2014.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface EightTracksStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
