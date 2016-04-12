//
//  DeezerStrategy.h
//  BeardedSpice
//
//  Created by Greg Woodcock on 01/06/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface DeezerStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
