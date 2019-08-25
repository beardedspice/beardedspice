//
//  EHLDeferBlock.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.2018.
//  Copyright (c) 2018 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - ACLDeferBlock

/**
 Class, which helps to execute block after some point in process.
 */
@interface EHLDeferBlock  : NSObject

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods

/**
 Create object, which execute block once when reach the counter value.
 Returned instance reacts on `count` method,
 when calling this method will reach defined value,  block will be executed.
 
 @param counterValue Defined value of the counter, which must be reached.
 @param queue Queue for execution of a block.
 @param block Block of a code for execution.
 @return Object instance.
 */
+ (instancetype)deferWithCounterValue:(NSUInteger)counterValue
                                queue:(dispatch_queue_t)queue
                                block:(dispatch_block_t)block;
/**
 Create object, which execute block when it deallocating.

 @param queue Queue for execution of a block.
 @param block Block of a code for execution.
 @return Object instance.
 */
+ (instancetype)deferWithQueue:(dispatch_queue_t)queue
                         block:(dispatch_block_t)block;

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods

/**
 Increases counter, when counter reaches the defined value, block is executed on queue asynchronous.
 Method is used with object instance, created by `deferWithCounterValue:queue:block:` method.
 */
- (void)count;

@end
