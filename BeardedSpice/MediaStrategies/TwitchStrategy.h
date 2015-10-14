//
//  TwitchStrategy.h
//  BeardedSpice
//
//  Created by Semyon Perepelitsa on 04.10.15.
//  Copyright © 2015 BeardedSpice. All rights reserved.
//

#import "MediaStrategy.h"

@interface TwitchStrategy : MediaStrategy
{
    NSPredicate *predicate;
}

@end
