//
//  EHExecuteBlockDelayed.m
//  EightHours
//
//  Created by Roman Sokolov on 25.02.17.
//  Copyright © 2017 Roman Sokolov. All rights reserved.
//

#import "EHExecuteBlockDelayed.h"

////////////////////////////////////////////////////////////////////
#pragma mark - EHExecuteBlockDelayed

@implementation EHExecuteBlockDelayed {
    
    dispatch_block_t _block;
    dispatch_queue_t _workQueue;
    dispatch_source_t _updateTimer;
    NSTimeInterval _interval;
    NSTimeInterval _leeway;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods

-(id)initWithTimeout:(NSTimeInterval)interval leeway:(NSTimeInterval)leeway queue:(dispatch_queue_t)queue block:(dispatch_block_t)block{
    
    self = [super init];
    if (self)
    {
        
        _workQueue = queue;
        _interval = interval;
        _leeway = leeway;
        _block = block;
    }
    
    return self;
}

- (void)dealloc{
    
    [self stopUpdateTimer];
    _workQueue = nil;
    _block = nil;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods

- (void)executeOnceAfterCalm{
    
    if (!_updateTimer){
        
        _updateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _workQueue);
        
        __weak __typeof__(self) wSelf = self;
        
        dispatch_source_set_event_handler(_updateTimer, ^{
            
            __typeof__(self) sSelf = wSelf;
            
            if (sSelf == nil) {
                return;
            }
            
            [sSelf stopUpdateTimer];
            sSelf->_block();
        });
        
        dispatch_resume(_updateTimer);
    }
    
    dispatch_source_set_timer(_updateTimer,
                              dispatch_time(DISPATCH_TIME_NOW, _interval * NSEC_PER_SEC),
                              _interval * NSEC_PER_SEC,
                              _leeway * NSEC_PER_SEC);
}

- (void)executeOnceForInterval{
    
    if (!_updateTimer){
        
        _updateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _workQueue);
        
        __weak __typeof__(self) wSelf = self;
        dispatch_source_set_event_handler(_updateTimer, ^{
            
            __typeof__(self) sSelf = wSelf;
            
            if (sSelf == nil) {
                return;
            }
            
            [sSelf stopUpdateTimer];
            sSelf->_block();
        });
        
        dispatch_resume(_updateTimer);
        
        dispatch_source_set_timer(_updateTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, _interval * NSEC_PER_SEC),
                                  _interval * NSEC_PER_SEC,
                                  _leeway * NSEC_PER_SEC);
    }
}

- (void)executeNow {
    
    __weak __typeof__(self) wSelf = self;
    
    dispatch_async(_workQueue, ^{
        
        __typeof__(self) sSelf = wSelf;
        
        if (sSelf == nil) {
            return;
        }
        
        sSelf->_block();
    });
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods

- (void)stopUpdateTimer{
    
    if (_updateTimer) {
        
        dispatch_source_cancel(_updateTimer);
        
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_updateTimer);
#endif
        _updateTimer = nil;
    }
    
}

@end
