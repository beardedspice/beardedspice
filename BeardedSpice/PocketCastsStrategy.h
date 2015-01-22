//
//  PocketCastsStrategy.h
//  BeardedSpice
//
//  Created by Dmytro Piliugin on 1/23/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface PocketCastsStrategy : MediaStrategy
{
    NSPredicate *predicate;
}
@end