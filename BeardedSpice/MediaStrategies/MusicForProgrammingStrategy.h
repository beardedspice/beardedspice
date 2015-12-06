//
//  MusicForProgrammingStrategy.h
//  BeardedSpice
//
//  Created by Max Borghino on 12/01/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface MusicForProgrammingStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end