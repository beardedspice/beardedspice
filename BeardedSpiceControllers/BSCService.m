//
//  BSCService.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSCService.h"
#import "BSSharedResources.h"
#import "BeardedSpiceHostAppProtocol.h"
#import "BSCShortcutMonitor.h"

//#include <IOKit/hid/IOHIDUsageTables.h>

#import "SPMediaKeyTap.h"
#import "DDHidAppleRemote.h"
#import "DDHidAppleMikey.h"

#import "EHSystemUtils.h"
#import "NSString+Utils.h"
#import "EHExecuteBlockDelayed.h"

#define MIKEY_REPEAT_TIMEOUT                0.6  //seconds

@implementation BSCService{

    SPMediaKeyTap *_keyTap;
    NSMutableArray *_mikeys;
    NSMutableArray *_appleRemotes;
    BSHeadphoneStatusListener *_hpuListener;

    NSMutableDictionary *_shortcuts;

    BOOL _remoteControlDaemonEnabled;
    BOOL _useAppleRemote;
    NSArray *_mediaKeysSupportedApps;

    dispatch_queue_t workingQueue;

    NSMutableArray *_connections;

    BOOL _enabled;

    EventLoopRef _shortcutThreadRL;
    
    EHExecuteBlockDelayed *_miKeyCommandBlock;
}

static BSCService *bscSingleton;

- (id)init{

    if (self == bscSingleton) {
        self = [super init];
        if (self) {

            [[NSUserDefaults standardUserDefaults] registerDefaults:@{kMediaKeyUsingBundleIdentifiersDefaultsKey: [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers]}];
            
            _connections = [NSMutableArray arrayWithCapacity:1];
            _shortcuts = [NSMutableDictionary dictionary];
            _remoteControlDaemonEnabled = NO;

            workingQueue = dispatch_queue_create("BeardedSpiceControllerService", DISPATCH_QUEUE_SERIAL);

            _hpuListener = [[BSHeadphoneStatusListener alloc] initWithDelegate:self listenerQueue:workingQueue];
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
                        [self->_shortcuts setObject:shortcut forKey:key];
                    }
                    else{
                        [self->_shortcuts removeObjectForKey:key];
                    }
                }];
                [self refreshShortcutMonitor];
            }
        }
    });
}

- (void)setMediaKeysSupportedApps:(NSArray <NSString *>*)bundleIds{
    dispatch_async(dispatch_get_main_queue(), ^{

        self->_keyTap.blackListBundleIdentifiers = [bundleIds copy];
        NSLog(@"Refresh Key Tab Black List.");
    });
}

- (void)setPhoneUnplugActionEnabled:(BOOL)enabled{

    dispatch_async(dispatch_get_main_queue(), ^{
        self->_hpuListener.enabled = enabled;
    });
}


- (void)setUsingAppleRemoteEnabled:(BOOL)enabled{

    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {

            self->_useAppleRemote = enabled;

            NSLog(@"Reset Apple Remote");

            if (self->_enabled && self->_useAppleRemote) {

                @try {
                    [self->_appleRemotes makeObjectsPerformSelector:@selector(stopListening)];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error when stopListenong on Apple Remotes: %@", exception);
                }


                @try {

                    NSArray *appleRemotes = [DDHidAppleRemote allRemotes];
                    self->_appleRemotes = [NSMutableArray arrayWithCapacity:appleRemotes.count];
                    for (DDHidAppleRemote *item in appleRemotes) {

                        @try {

                            [item setDelegate:self];
                            [item setListenInExclusiveMode:YES];
                            [item startListening];

                            [self->_appleRemotes addObject:item];
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
                    [self->_appleRemotes makeObjectsPerformSelector:@selector(stopListening)];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error when stopListenong on Apple Remotes: %@", exception);
                }
                self->_appleRemotes = nil;
            }
        }
    });
}


- (BOOL)addConnection:(NSXPCConnection *)connection{
    dispatch_sync(dispatch_get_main_queue(), ^{

        if (connection) {
            if (!_enabled) {
                [self rcdControl];
                [self refreshShortcutMonitor];
                _enabled = [self refreshAllControllers:nil];
            }
            if (_enabled) {
                [_connections addObject:connection];
            }
        }
    });
    return _enabled;
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
    BS_LOG(LOG_DEBUG, @"headphoneUnplugAction");
    [self sendMessagesToConnections:@selector(headphoneUnplug)];
}

- (void)headphonePlugAction
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BS_LOG(LOG_DEBUG, @"headphonePlugAction");
        [self refreshMikeys];
    });
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
            case NX_KEYTYPE_SOUND_UP:
                debugString = [@"Sound Up pressed" stringByAppendingString:debugString];
                [self sendMessagesToConnections:@selector(volumeUp)];
                break;
            case NX_KEYTYPE_SOUND_DOWN:
                debugString = [@"Sound Down pressed" stringByAppendingString:debugString];
                [self sendMessagesToConnections:@selector(volumeDown)];
                break;
            case NX_KEYTYPE_MUTE:
                debugString = [@"Sound Mute pressed" stringByAppendingString:debugString];
                [self sendMessagesToConnections:@selector(volumeMute)];
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
#if DEBUG
    NSLog(@"Apple Mikey keypress detected: x%X", usageId);
#endif
    if (upOrDown == TRUE) {
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
            case kHIDUsage_Csmr_VolumeIncrement:
                [self sendMessagesToConnections:@selector(volumeUp)];
                break;
            case kHIDUsage_GD_SystemMenuDown:
            case kHIDUsage_Csmr_VolumeDecrement:
                [self sendMessagesToConnections:@selector(volumeDown)];
                break;
            case kHIDUsage_Csmr_PlayOrPause:
                [self catchCommandFromMiKeys];
            default:
                NSLog(@"Unknown key press seen x%X", usageId);
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

- (BOOL)refreshMediaKeys{

    __block BOOL result = YES;
    [EHSystemUtils callOnMainQueue:^{
        if (self->_enabled) {
            result = [self->_keyTap startWatchingMediaKeys];
        }
        else {
            [self->_keyTap stopWatchingMediaKeys];
        }
    }];

    return result;
}

- (void)catchCommandFromMiKeys {
    static NSInteger counter = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _miKeyCommandBlock  = [[EHExecuteBlockDelayed alloc]
                               initWithTimeout:MIKEY_REPEAT_TIMEOUT
                               leeway:MIKEY_REPEAT_TIMEOUT
                               queue:workingQueue
                               block:^{
                                   switch (counter) {
                                       case 1:
                                           [self sendMessagesToConnections:@selector(playPauseToggle)];
                                           break;
                                           
                                       case 2:
                                           [self sendMessagesToConnections:@selector(nextTrack)];
                                           break;
                                           
                                       case 3:
                                           [self sendMessagesToConnections:@selector(previousTrack)];
                                           break;

                                       default:
                                           break;
                                   }
                                   BS_LOG(LOG_DEBUG, @"%s - Comman Block Running (%ld)", __FUNCTION__, counter);
                                   counter = 0;
                               }];
    });
    
    counter++;
    BS_LOG(LOG_DEBUG, @"%s - counter: %ld", __FUNCTION__, counter);
    [_miKeyCommandBlock executeOnceAfterCalm];
}

- (void)refreshMikeys
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {

            NSLog(@"Reset Mikeys");

            if (self->_mikeys != nil) {
                @try {
                    [self->_mikeys makeObjectsPerformSelector:@selector(stopListening)];
                }
                @catch (NSException *exception) {
                    NSLog(@"Error when stopListening on Apple Mic: %@", exception);
                }
            }

            if (self->_enabled) {
                @try {
                    NSArray *mikeys = [DDHidAppleMikey allMikeys];
                    self->_mikeys = [NSMutableArray arrayWithCapacity:mikeys.count];
                    for (DDHidAppleMikey *item in mikeys) {

                        @try {

                            [item setDelegate:self];
                            [item setListenInExclusiveMode:YES];
                            [item startListening];

                            [self->_mikeys addObject:item];
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
            if (self->_enabled) {

                MASShortcut *shortcut = self->_shortcuts[BeardedSpicePlayPauseShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self sendMessagesToConnections:@selector(playPauseToggle)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpiceNextTrackShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self sendMessagesToConnections:@selector(nextTrack)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpicePreviousTrackShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self sendMessagesToConnections:@selector(previousTrack)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpiceActiveTabShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self refreshMediaKeys];
                        
                        [self sendMessagesToConnections:@selector(activeTab)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpiceFavoriteShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self sendMessagesToConnections:@selector(favorite)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpiceNotificationShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self refreshMediaKeys];
                        
                        [self sendMessagesToConnections:@selector(notification)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpiceActivatePlayingTabShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{
                        
                        [self refreshMediaKeys];

                        [self sendMessagesToConnections:@selector(activatePlayingTab)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpicePlayerNextShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self refreshMediaKeys];

                        [self sendMessagesToConnections:@selector(playerNext)];
                    }];
                }

                shortcut = self->_shortcuts[BeardedSpicePlayerPreviousShortcut];
                if (shortcut){
                    [[BSCShortcutMonitor sharedMonitor] registerShortcut:shortcut withAction:^{

                        [self refreshMediaKeys];
                        
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

            for (NSXPCConnection *conn in self->_connections) {

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
        BS_LOG(LOG_DEBUG, @"rcdControl enabled");
        //checking that rcd is enabled and disabling it
        NSString *cliOutput = NULL;
        if ([EHSystemUtils cliUtil:@"/bin/launchctl" arguments:@[@"list"] output:&cliOutput] == 0) {
            _remoteControlDaemonEnabled = ( [cliOutput contains:@"com.apple.rcd" caseSensitive:YES]);
            if (_remoteControlDaemonEnabled) {
                _remoteControlDaemonEnabled = ([EHSystemUtils cliUtil:@"/bin/launchctl" arguments:@[@"unload", @"-w", @"com.apple.rcd.plist"] output:nil] == 0);
                BS_LOG(LOG_DEBUG, @"rcdControl unload result: %d", _remoteControlDaemonEnabled);
            }
        }
    }
    else{

        BS_LOG(LOG_DEBUG, @"rcdControl disable");
        if (_remoteControlDaemonEnabled) {
            BS_LOG(LOG_DEBUG, @"rcdControl load");
            [EHSystemUtils cliUtil:@"/bin/launchctl" arguments:@[@"load", @"-w", @"/System/Library/LaunchAgents/com.apple.rcd.plist"] output:nil];
        }
    }

}

#pragma mark - Notifications

/**
 Method reloads: media keys, apple remote, headphones remote.
 */
- (BOOL)refreshAllControllers:(NSNotification *)note
{
    [self refreshMikeys];
    if ([self refreshMediaKeys] == NO) {
        return NO;
    }
    [self setUsingAppleRemoteEnabled:_useAppleRemote];
    return YES;
}

@end
