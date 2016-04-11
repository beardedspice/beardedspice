//
//  SomaFmStrategy.h
//  BeardedSpice
//
//  Created by Max Borghino on 1/28/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface SomaFmStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end