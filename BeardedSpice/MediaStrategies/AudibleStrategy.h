//
//  AudibleStrategy.h
//  BeardedSpice
//
//  Created by Max Borghino on 12/06/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface AudibleStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
