//
//  YandexMusicStrategy.h
//  BeardedSpice
//
//  Created by Leonid Ponomarev 15.06.15
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface YandexRadioStrategy : MediaStrategy
{
    NSPredicate *predicate;
    NSDictionary *_nextTrackInfo;
}

@end
