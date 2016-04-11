//
//  YandexMusicStrategy.h
//  BeardedSpice
//
//  Created by Vladimir Burdukov on 3/14/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface YandexMusicStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
