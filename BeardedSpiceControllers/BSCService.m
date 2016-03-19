//
//  BSCService.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "BSCService.h"
#import "BSSharedDefaults.h"
#import "BeardedSpiceHostAppProtocol.h"
#import "BSCShortcutMonitor.h"

//#include <IOKit/hid/IOHIDUsageTables.h>

#import "SPMediaKeyTap.h"
#import "DDHidAppleRemote.h"
#import "DDHidAppleMikey.h"

#import "EHSystemUtils.h"

@implementation BSCService{
    
    SPMediaKeyTap *_keyTap;
    NSMutableArray *_mikeys;
    NSMutableArray *_appleRemotes;
    BSHeadphoneUnplugListener *_hpuListener;
    
    NSMutableDictionary *_shortcuts;
    
    BOOL _remoteControlDaemonEnabled;
    BOOL _useAppleRemote;
    NSArray *_mediaKeysSupportedApps;

    dispatch_queue_t workingQueue;
    
    NSMutableArray *_connections;
    
    BOOL _enabled;
    
    EventLoopRef _shortcutThreadRL;
}

static BSCService *bscSingleton;

- (id)init{
    
    if (self == bscSingleton) {
        self = [super init];
        if (self) {
            
            _connections = [NSMutableArray arrayWithCapacity:1];
            _shortcuts = [NSMutableDictionary dictionary];
            _remoteControlDaemonEnabled = NO;

            workingQueue = dispatch_queue_create("BeardedSpiceControllerService", DISPATCH_QUEUE_SERIAL);
            
            _hpuListener = [[BSHeadphoneUnplugListener alloc] initWithDelegate:self];
            _keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
            
            
            // System notifications
            [[[NSWorkspace sharedWorkspace] notificationCenter]
             addObserver: self
             selector: @selector(refreshAllControllers:)
             name: NSWorkspaceScreensDidWakeNotification
             object: NULL];
            
            NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
            [center
             addObserver: self
             selector: @selector(refreshAllControllers:)
             name: @"com.apple.screenIsUnlocked"
             object: NULL];
            
            [center
             addObserver: self
             selector: @selector(refreshAllControllers:)
             name: @"com.apple.screensaver.didstop"
             object: NULL];
            //--------------------------------------------
            
//            [BSCShortcutMonitor sharedMonitor];

        }
        return self;
    }
    
    return nil;
}

- (void)dealloc{
    
    if (_shortcutThreadRL) {
        QuitEventLoop(_shortcutThreadRL);
    }
}

+ (BSCService *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        bscSingleton = [BSCService alloc];
        bscSingleton = [bscSingleton init];
    });
    
    return bscSingleton;
}

#pragma mark - Public Methods

- (void)setShortcuts:(NSDictionary *)shortcuts{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
    
            if (shortcuts) {
            
                [shortcuts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    MASShortcut *shortcut = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
                    if (shortcut) {
                        [_shortcuts setObject:shortcut forKey:key];
                    }
                    else{
                        [_shortcuts removeObjectForKey:key];
                    }
                }];
                [self refreshShortcutMonitor];
            }
        }
    });
}

- (void)setMediaKeysSupportedApps:(NSArray <NSString *>*)bundleIds{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _keyTap.blackListBundleIdentifiers = [bundleIds copy];
        NSLog(@"Refresh Key Tab Black List.");
    });
}

- (void)setPhoneUnplugActionEnabled:(BOOL)enabled{

    dispatch_async(dispatch_get_main_queue(), ^{
        _hpuListener.enabled = enabled;
    });
}


- (void)setUsingAppleRemoteEnabled:(BOOL)enabled{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            
            _useAppleRemote = enabled;
            
            NSLog(@"Reset Apple Remote");
            
            if (_enabled && _useAppleRemote) {
                
                @try {
                    [_appleRemotes makeObjectsPerformSelector:@selector(stopListening)];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error when stopListenong on Apple Remotes: %@", exception);
                }
                
                
                @try {
                    
                    NSArray *appleRemotes = [DDHidAppleRemote allRemotes];
                    _appleRemotes = [NSMutableArray arrayWithCapacity:appleRemotes.count];
                    for (DDHidAppleRemote *item in appleRemotes) {
                        
                        @try {
                            
                            [item setDelegate:self];
                            [item setListenInExclusiveMode:YES];
                            [item startListening];
                            
                            [_appleRemotes addObject:item];
#if DEBUG
                            NSLog(@"Apple Remote added - %@", item);
#endif
                        }
                        @catch (NSException *exception) {
                            
                            NSLog(@"Error when startListening on Apple Remote: %@, exception: %@", item, exception);
                        }
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Error of the obtaining Apple Remotes divices: %@", [exception description]);
                }
            } else {
                
                @try {
                    [_appleRemotes makeObjectsPerformSelector:@selector(stopListening)];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error when stopListenong on Apple Remotes: %@", exception);
                }
                _appleRemotes = nil;
            }
        }
    });
}


- (void)addConnection:(NSXPCConnection *)connection{
    dispatch_sync(dispatch_get_main_queue(), ^{
       
        if (connection) {
            [_connections addObject:connection];
            if (!_enabled) {
                _enabled = YES;
                [self rcdControl];
                [self refreshShortcutMonitor];
                [self refreshAllControllers:nil];
            }
        }
    });
}
- (void)removeConnection:(NSXPCConnection *)connection{
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if (connection) {
            [_connections removeObject:connection];
            if (!_connections.count && _enabled) {
                _enabled = NO;
                [self rcdControl];
                [self refreshShortcutMonitor];
                [self refreshAllControllers:nil];
            }
        }
    });
}


#pragma mark - Events Handlers

// Performs Pause method
- (void)headphoneUnplugAction{
    
    [self sendMessagesToConnections:@selector(headphoneUnplug)];
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
    NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
    // here be dragons...
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    int keyRepeat = (keyFlags & 0x1);
    
    if (keyIsPressed) {
        
        NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
                [self sendMessagesToConnections:@selector(playPauseToggle)];
                break;
            case NX_KEYTYPE_FAST:
            case NX_KEYTYPE_NEXT:
                debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [self sendMessagesToConnections:@selector(nextTrack)];
                break;
            case NX_KEYTYPE_REWIND:
            case NX_KEYTYPE_PREVIOUS:
                debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                [self sendMessagesToConnections:@selector(previousTrack)];
                break;
            default:
                debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
                break;
                // More cases defined in hidsystem/ev_keymap.h
        }
        
        NSLog(@"%@", debugString);
    }
}

- (void) ddhidAppleMikey:(DDHidAppleMikey *)mikey press:(unsigned)usageId upOrDown:(BOOL)upOrDown
{
    if (upOrDown == TRUE) {
#if DEBUG
        NSLog(@"Apple Mikey keypress detected: %d", usageId);
#endif
        switch (usageId) {
            case kHIDUsage_GD_SystemMenu:
                [self sendMessagesToConnections:@selector(playPauseToggle)];
                break;
            case kHIDUsage_GD_SystemMenuRight:
                [self sendMessagesToConnections:@selector(nextTrack)];
                break;
            case kHIDUsage_GD_SystemMenuLeft:
                [self sendMessagesToConnections:@selector(previousTrack)];
                break;
            case kHIDUsage_GD_SystemMenuUp:
                [self sendMessagesToConnections:@selector(volumeUp)];
                break;
            case kHIDUsage_GD_SystemMenuDown:
                [self sendMessagesToConnections:@selector(volumeDown)];
                break;
            default:
                NSLog(@"Unknown key press seen %d", usageId);
        }
    }
}

- (void) ddhidAppleRemoteButton: (DDHidAppleRemoteEventIdentifier) buttonIdentifier
                    pressedDown: (BOOL) pressedDown{
    
    if (pressedDown) {
        
        switch (buttonIdentifier) {
            case kDDHidRemoteButtonVolume_Plus:
                [self sendMessagesToConnections:@selector(volumeUp)];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonVolume_Plus");
                break;
            case kDDHidRemoteButtonVolume_Minus:
                [self sendMessagesToConnections:@selector(volumeDown)];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonVolume_Minus");
                break;
            case kDDHidRemoteButtonMenu:
                [self sendMessagesToConnections:@selector(playerNext)];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonMenu");
                break;
            case kDDHidRemoteButtonPlay:
            case kDDHidRemoteButtonPlayPause:
                [self sendMessagesToConnections:@selector(playPauseToggle)];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonPlay");
                break;
            case kDDHidRemoteButtonRight:
                [self sendMessagesToConnections:@selector(nextTrack)];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonRight");
                break;
            case kDDHidRemoteButtonLeft:
                [self sendMessagesToConnections:@selector(previousTrack)];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonLeft");
                break;
            case kDDHidRemoteButtonRight_Hold:
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonRight_Hold");
                break;
            case kDDHidRemoteButtonMenu_Hold:
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonMenu_Hold");
                break;
            case kDDHidRemoteButtonLeft_Hold:
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonLeft_Hold");
                break;
            case kDDHidRemoteButtonPlay_Sleep:
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonPlay_Sleep");
                break;
            case kDDHidRemoteControl_Switched:
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteControl_Switched");
                break;
            default:
                NSLog(@"Apple Remote keypress detected: Unknown key press seen %d", buttonIdentifier);
        }
    }
}

#pragma mark - Private Methods

- (void)refreshMediaKeys{

    dispatch_async(dispatch_get_main_queue(), ^{
        if (_enabled) {
            [_keyTap startWatchingMediaKeys];
        }
        else {
            [_keyTap stopWatchingMediaKeys];
        }
    });
}

- (void)refreshMikeys
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            
            NSLog(@"Reset Mikeys");
            
            if (_mikeys != nil) {
                @try {
                    [_mikeys makeObjectsPerformSelector:@selector(stopListening)];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error when stopListenong on Apple Mic: %@", exception);
                }
            }
            
            if (_enabled) {
                @try {
                    NSArray *mikeys = [DDHidAppleMikey allMikeys];
                    _mikeys = [NSMutableArray arrayWithCapacity:mikeys.count];
                    for (DDHidAppleMikey *item in mikeys) {
                        
                        @try {
                            
                            [item setDelegate:self];
                            [item setListenInExclusiveMode:NO];
                            [item startListening];
                            
                            [_mikeys addObject:item];
#if DEBUG
                            NSLog(@"Apple Mic added - %@", item);
#endif
                        }
                        @catch (NSException *exception) {
                            
                            NSLog(@"Error when startListening on Apple Mic: %@, exception: %@", item, exception);
                        }
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Error of the obtaining Apple Mic divices: %@", [exception description]);
                }
            }
        }
    });
}

- (void)refreshShortcutMonitor{
    
    dispatch_async(workingQueue, ^{
        @autoreleasepool {
    
            [[BSCShortcutMonitor sharedMonitor] unregisterAllShortcuts];
            if (_enabled) {
                
                MASShortcut *shortcut = _shortcuts[BeardedSpicePlayPauseShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                       
                        [self sendMessagesToConnections:@selector(playPauseToggle)];
                    }];
                }
                
                shortcut = _shortcuts[BeardedSpiceNextTrackShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(nextTrack)];
                    }];
                }
                
                shortcut = _shortcuts[BeardedSpicePreviousTrackShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(previousTrack)];
                    }];
                }
                
                shortcut = _shortcuts[BeardedSpiceActiveTabShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(activeTab)];
                    }];
                }

                shortcut = _shortcuts[BeardedSpiceFavoriteShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(favorite)];
                    }];
                }

                shortcut = _shortcuts[BeardedSpiceNotificationShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(notification)];
                    }];
                }

                shortcut = _shortcuts[BeardedSpiceActivatePlayingTabShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(activatePlayingTab)];
                    }];
                }

                shortcut = _shortcuts[BeardedSpicePlayerNextShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(playerNext)];
                    }];
                }

                shortcut = _shortcuts[BeardedSpicePlayerPreviousShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self sendMessagesToConnections:@selector(playerPrevious)];
                    }];
                }

            }
        }
    });
}

- (void)sendMessagesToConnections:(SEL)selector{
    
    dispatch_async(workingQueue, ^{
        @autoreleasepool {
       
            for (NSXPCConnection *conn in _connections) {
                
                id<BeardedSpiceHostAppProtocol, NSObject> obj = [conn remoteObjectProxy];
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [obj performSelector:selector];
#pragma clang diagnostic pop
            }
        }
    });
}

- (void)rcdControl{
    
    if (_enabled) {
        //checking that rcd is enabled and disabling it
        NSString *cliOutput = NULL;
        if ([EHSystemUtils cliUtil:@"/bin/launchctl" arguments:@[@"list"] output:&cliOutput] == 0) {
            _remoteControlDaemonEnabled = [cliOutput containsString:@"com.apple.rcd"];
            if (_remoteControlDaemonEnabled) {
                _remoteControlDaemonEnabled = ([EHSystemUtils cliUtil:@"/bin/launchctl" arguments:@[@"unload", @"/System/Library/LaunchAgents/com.apple.rcd.plist"] output:nil] == 0);
            }
        }
    }
    else{
        
        if (_remoteControlDaemonEnabled) {
            
            [EHSystemUtils cliUtil:@"/bin/launchctl" arguments:@[@"load", @"/System/Library/LaunchAgents/com.apple.rcd.plist"] output:nil];
        }
    }
}

#pragma mark - Notifications

/**
 Method reloads: media keys, apple remote, headphones remote.
 */
- (void)refreshAllControllers:(NSNotification *)note
{
    [self refreshMikeys];
    [self refreshMediaKeys];
    [self setUsingAppleRemoteEnabled:_useAppleRemote];
}

@end
