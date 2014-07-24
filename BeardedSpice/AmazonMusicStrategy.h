//
//  AmazonMusicStrategy.h
//  BeardedSpice
//
//  Created by Brandon P Smith on 7/23/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface AmazonMusicStrategy : MediaStrategy
{
    NSPredicate *predicate;
}
@end
