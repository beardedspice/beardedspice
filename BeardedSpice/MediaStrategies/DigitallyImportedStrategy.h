    //
//  DigitallyImportedStrategy.h
//  BeardedSpice
//
//  Created by Dennis Lysenko on 4/4/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaStrategy.h"

@interface DigitallyImportedStrategy : MediaStrategy <MediaStrategyProtocol>
{
    NSPredicate *predicate;
}

@end
