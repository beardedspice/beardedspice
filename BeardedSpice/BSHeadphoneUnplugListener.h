//
//  BSHeadphoneUnplugListener.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.08.15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - BSHeadphoneUnplugListener
/////////////////////////////////////////////////////////////////////

@protocol BSHeadphoneUnplugListenerProtocol <NSObject>

/**
    Action is called when headphone is unplugged.
 */
- (void)headphoneUnplugAction;

@end

/////////////////////////////////////////////////////////////////////
#pragma mark - BSHeadphoneUnplugListener
/////////////////////////////////////////////////////////////////////

/**
    Monitoring mini-jack connection. 
    Attempt to determine unplugging headphone from it. 
    And perform action when raises this event.
 */
@interface BSHeadphoneUnplugListener : NSObject{
    
    AudioDeviceID _defaultDevice;
    UInt32        _sourceId;
    AudioObjectPropertyAddress _sourceAddr;
    
    AudioObjectPropertyListenerBlock _listenerBlock;
    dispatch_queue_t    _listenerQueue;
    
    BOOL _enabled;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Init and class methods
/////////////////////////////////////////////////////////////////////

- (BSHeadphoneUnplugListener *)initWithDelegate:(id<BSHeadphoneUnplugListenerProtocol>)delegate;

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods
/////////////////////////////////////////////////////////////////////

@property (weak, readonly, nonatomic) id<BSHeadphoneUnplugListenerProtocol> delegate;

@property BOOL enabled;

@end
