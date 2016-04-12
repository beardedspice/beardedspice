//
//  AudioMackStrategy.h
//  BeardedSpice
//
//  Created by Sean Coker on 12/11/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface AudioMackStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
