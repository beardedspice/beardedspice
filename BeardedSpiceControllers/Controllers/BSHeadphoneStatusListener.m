//
//  BSHeadphoneUnplugListener.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.08.15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BSHeadphoneStatusListener.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - BSHeadphoneUnplugListener
/////////////////////////////////////////////////////////////////////

@implementation BSHeadphoneStatusListener {

    AudioDeviceID _defaultDevice;
    UInt32        _sourceId;
    AudioObjectPropertyAddress _sourceAddr;

    AudioObjectPropertyListenerBlock _changeDefaultListenerBlock;
    AudioObjectPropertyListenerBlock _changeSourceListenerBlock;
    dispatch_queue_t    _listenerQueue;

    BOOL _enabled;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Init and class methods
/////////////////////////////////////////////////////////////////////

- (BSHeadphoneStatusListener *)initWithDelegate:(id<BSHeadphoneStatusListenerProtocol>)delegate
                                  listenerQueue:(dispatch_queue_t)listenerQueue {

    if (!(delegate && listenerQueue)) {
        return nil;
    }
    self = [super init];
    if (self) {
        _delegate = delegate;
        _listenerQueue = listenerQueue;
        
        _sourceAddr.mSelector = kAudioDevicePropertyDataSource;
        _sourceAddr.mScope = kAudioDevicePropertyScopeOutput;
        _sourceAddr.mElement = kAudioObjectPropertyElementMaster;

        ASSIGN_WEAK(self);

        _changeDefaultListenerBlock = ^(UInt32 inNumberAddresses,
                           const AudioObjectPropertyAddress *inAddresses) {
            ASSIGN_STRONG(self);

            [USE_STRONG(self) removeCallbackForDevice];
            if ([USE_STRONG(self) getDefaultDevice]) {
                [USE_STRONG(self) getCurrentSource];
                [USE_STRONG(self) addCallbackForDevice];
            }
        };

        _changeSourceListenerBlock = ^(UInt32 inNumberAddresses,
                           const AudioObjectPropertyAddress *inAddresses) {
            ASSIGN_STRONG(self);
            UInt32 oldSourceId = USE_STRONG(self)->_sourceId;
            [USE_STRONG(self) getCurrentSource];

            if (USE_STRONG(self)->_sourceId != oldSourceId) {
                if (oldSourceId == 'hdpn') {
                    dispatch_async(USE_STRONG(self)->_listenerQueue, ^{
                        [USE_STRONG(self).delegate headphoneUnplugAction];
                    });
                } else if (USE_STRONG(self)->_sourceId == 'hdpn') {
                    dispatch_async(USE_STRONG(self)->_listenerQueue, ^{
                        [USE_STRONG(self).delegate headphonePlugAction];
                    });
                }
            }
        };
     
        _enabled = NO;
    }
    return self;
}

- (void)dealloc{
    
    [self removeCallback];
}

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods
/////////////////////////////////////////////////////////////////////

- (BOOL)enabled{
    @synchronized(self){
        return _enabled;
    }
}

- (void)setEnabled:(BOOL)enabled{

    @synchronized(self){
    [self willChangeValueForKey:@"enabled"];
    
        if (enabled != _enabled) {
            
            if (enabled) {
                if ([self addCallback]) {
                    _enabled = YES;
                }
            }
            else{
                if ([self removeCallback]) {
                    _enabled = NO;
                }
            }
        }
    
    [self didChangeValueForKey:@"enabled"];
    }
}

/////////////////////////////////////////////////////////////////////
#pragma mark Private methods
/////////////////////////////////////////////////////////////////////

- (BOOL)addCallback {

    [self getDefaultDevice];
    [self getCurrentSource];

    const AudioObjectPropertyAddress defaultAddr = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };

    __block OSStatus result = 1;
    ASSIGN_WEAK(self);
    dispatch_sync(_listenerQueue, ^{
        ASSIGN_STRONG(self);
        result = ! [USE_STRONG(self) addCallbackForDevice];
    });
    if (result == 0) {
        result = AudioObjectAddPropertyListenerBlock(kAudioObjectSystemObject, &defaultAddr, _listenerQueue, _changeDefaultListenerBlock);
    }

    return !result;
}

- (BOOL)removeCallback{
    
    const AudioObjectPropertyAddress defaultAddr = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };

    __block OSStatus result = 1;
    if (_listenerQueue) {
        
         result = AudioObjectRemovePropertyListenerBlock(kAudioObjectSystemObject, &defaultAddr, _listenerQueue, _changeDefaultListenerBlock);
        if (result == 0) {
            ASSIGN_WEAK(self);
            dispatch_sync(_listenerQueue, ^{
                ASSIGN_STRONG(self);
                result = ! [USE_STRONG(self) removeCallbackForDevice];
            });
        }
    }

    _defaultDevice = _sourceId = 0;
    
    return !result;
}

- (BOOL)addCallbackForDevice {

    if (_defaultDevice) {
        return ! AudioObjectAddPropertyListenerBlock(_defaultDevice, &_sourceAddr, _listenerQueue, _changeSourceListenerBlock);
    }

    return NO;
}

- (BOOL)removeCallbackForDevice{

    OSStatus result = 0;
    if (_listenerQueue && _defaultDevice) {

        result = AudioObjectRemovePropertyListenerBlock(_defaultDevice, &_sourceAddr, _listenerQueue, _changeSourceListenerBlock);
    }
    return !result;
}

- (BOOL)getCurrentSource{
    
    _sourceId = 0;
    UInt32 dataSourceIdSize = sizeof(_sourceId);
    return ! AudioObjectGetPropertyData(_defaultDevice, &_sourceAddr, 0, NULL,
                                          &dataSourceIdSize, &_sourceId);
}

- (BOOL)getDefaultDevice {
    _defaultDevice = 0;
    UInt32 defaultSize = sizeof(AudioDeviceID);
    const AudioObjectPropertyAddress defaultAddr = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };

    return ! AudioObjectGetPropertyData(kAudioObjectSystemObject, &defaultAddr, 0, NULL, &defaultSize, &_defaultDevice);

}
@end
