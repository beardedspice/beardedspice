//
//  BopFm.h
//  BeardedSpice
//
//  Created by Jose Falcon on 7/22/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface BopFm : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}
@end