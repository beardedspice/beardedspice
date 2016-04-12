//
//  KollektFmStrategy.h
//  BeardedSpice
//
//  Created by Wiert Omta on 23/1/2015.
//  Copyright (c) 2015 Wiert Omta. All rights reserved.
//

#import "MediaStrategy.h"

@interface KollektFmStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
