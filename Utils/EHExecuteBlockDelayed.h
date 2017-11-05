//
//  EHExecuteBlockDelayed.h
//  EightHours
//
//  Created by Roman Sokolov on 25.02.17.
//  Copyright © 2017 Roman Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHExecuteBlockDelayed : NSObject

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods

-(id)initWithTimeout:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods

- (void)executeOnceAfterCalm;
- (void)executeOnceForInterval;
- (void)executeNow;

@end
