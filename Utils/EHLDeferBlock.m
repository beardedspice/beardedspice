//
//  EHLDeferBlock.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.2018.
//  Copyright (c) 2018 BeardedSpice. All rights reserved.
//

#import "EHLDeferBlock.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - ACLDeferBlock

typedef NS_ENUM(Byte, ExecMode) {
    ExecModeDefer,
    ExecModeCounter
};

@implementation EHLDeferBlock {
    ExecMode _mode;
    dispatch_block_t _block;
    dispatch_queue_t _workingQueue;
    NSUInteger _counterValue;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods

- (void)dealloc {
    
    if (_mode == ExecModeDefer) {
        __weak __typeof__(self) wSelf = self;
        
        dispatch_async(_workingQueue, ^{
            __typeof__(self) sSelf = wSelf;
            
            if (sSelf == nil) {
                return;
            }
            
            sSelf->_block();
        });

    }
}

+ (instancetype)deferWithCounterValue:(NSUInteger)counterValue queue:(dispatch_queue_t)queue block:(dispatch_block_t)block {
    
    if (counterValue == 0 || queue == nil || block == nil) {
        return nil;
    }

    EHLDeferBlock *_self = [EHLDeferBlock new];
    if (_self) {
        
        _self->_mode = ExecModeCounter;
        _self->_counterValue = counterValue;
        _self->_workingQueue = queue;
        _self->_block = block;
    }
    
    return _self;
}

+ (instancetype)deferWithQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {
    
    if (queue == nil || block == nil) {
        return nil;
    }
    
    EHLDeferBlock *_self = [EHLDeferBlock new];
    if (_self) {
        _self->_mode = ExecModeDefer;
        _self->_counterValue = 0;
        _self->_workingQueue = queue;
        _self->_block = block;
    }
    __weak EHLDeferBlock *result = _self;
    return result;
}
/////////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods

- (void)count {
    
    if (_mode == ExecModeCounter && _counterValue) {
        
        _counterValue--;
        if (_counterValue == 0) {
            
//            __weak __typeof__(self) wSelf = self;
            dispatch_async(_workingQueue, ^{
//                __typeof__(self) sSelf = wSelf;
                
//                if (sSelf == nil) {
//                    return;
//                }
                
                self->_block();
            });
            
        }
    }
}

@end
