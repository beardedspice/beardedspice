//
//  GoogleMusicStrategy.h
//  BeardedSpice
//
//  Created by Jose Falcon on 1/9/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface GoogleMusicStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
