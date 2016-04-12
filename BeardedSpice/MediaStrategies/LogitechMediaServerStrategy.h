//
//  GrooveSharkStrategy.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface LogitechMediaServerStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}
@end