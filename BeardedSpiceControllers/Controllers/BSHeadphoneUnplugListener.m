//
//  BSHeadphoneUnplugListener.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 08.08.15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BSHeadphoneUnplugListener.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - BSHeadphoneUnplugListener
/////////////////////////////////////////////////////////////////////

@implementation BSHeadphoneUnplugListener

/////////////////////////////////////////////////////////////////////
#pragma mark Init and class methods
/////////////////////////////////////////////////////////////////////

- (BSHeadphoneUnplugListener *)initWithDelegate:(id<BSHeadphoneUnplugListenerProtocol>)delegate{
    
    if (!delegate) {
        return nil;
    }
    self = [super init];
    if (self) {
        _delegate = delegate;
        
        _defaultDevice = _sourceId = 0;
        UInt32 defaultSize = sizeof(AudioDeviceID);
        
        const AudioObjectPropertyAddress defaultAddr = {
            kAudioHardwarePropertyDefaultOutputDevice,
            kAudioObjectPropertyScopeGlobal,
            kAudioObjectPropertyElementMaster
        };
        
        _sourceAddr.mSelector = kAudioDevicePropertyDataSource;
        _sourceAddr.mScope = kAudioDevicePropertyScopeOutput;
        _sourceAddr.mElement = kAudioObjectPropertyElementMaster;
        
        AudioObjectGetPropertyData(kAudioObjectSystemObject, &defaultAddr, 0, NULL, &defaultSize, &_defaultDevice);
        
        __weak BSHeadphoneUnplugListener *bself = self;
        _listenerBlock = ^(UInt32 inNumberAddresses,
                           const AudioObjectPropertyAddress *inAddresses) {
            
            UInt32 newSourceId = [bself currentSource:(AudioObjectPropertyAddress *)inAddresses];
            
            if (_sourceId == 'hdpn' && _sourceId != newSourceId) {
                dispatch_async(dispatch_get_current_queue(), ^{
                    [bself.delegate headphoneUnplugAction];
                });
            }
            _sourceId = newSourceId;
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
                _sourceId = [self currentSource:&_sourceAddr];
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
    _listenerQueue = dispatch_get_current_queue();

    OSStatus result = AudioObjectAddPropertyListenerBlock(
        _defaultDevice, &_sourceAddr, _listenerQueue, _listenerBlock);

    return !result;
}

- (BOOL)removeCallback{
    
    OSStatus result = 1;
    if (_listenerQueue) {
        
         result = AudioObjectRemovePropertyListenerBlock(_defaultDevice, &_sourceAddr, _listenerQueue, _listenerBlock);
        
        if (!result) {
            _listenerQueue = nil;
        }
        
    }
    return !result;
}

- (UInt32)currentSource:(AudioObjectPropertyAddress *)sourceAddr{
    
    UInt32 dataSourceId = 0;
    UInt32 dataSourceIdSize = sizeof(UInt32);
    AudioObjectGetPropertyData(_defaultDevice, sourceAddr, 0, NULL,
                               &dataSourceIdSize, &dataSourceId);
    
    return dataSourceId;
}

@end
