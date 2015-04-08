//
//  SubsonicStrategy.h
//  BeardedSpice
//
//  Created by Michael Alden on 4/8/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface SubsonicStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
