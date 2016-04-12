//
//  SubsonicStrategy.h
//  BeardedSpice
//
//  Created by Michael Alden on 6/16/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface SubsonicStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
