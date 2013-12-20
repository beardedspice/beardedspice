//
//  LastFmStrategy.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/19/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface LastFmStrategy : MediaStrategy
{
    NSPredicate *predicate;
}
@end
