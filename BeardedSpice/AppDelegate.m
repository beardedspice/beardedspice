//
//  AppDelegate.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#include <IOKit/hidsystem/ev_keymap.h>

#import "AppDelegate.h"

#import "BSNativeAppTabAdapter.h"

#import "BSSharedResources.h"
#import "BeardedSpiceControllersProtocol.h"

#import "BSPreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"
#import "ShortcutsPreferencesViewController.h"
#import "BSStrategiesPreferencesViewController.h"
#import "NSString+Utils.h"
#import "BSTimeout.h"

#import "BSActiveTab.h"

#import "BSStrategyCache.h"
#import "BSTrack.h"
#import "BSStrategyVersionManager.h"
#import "BSCustomStrategyManager.h"

#import "runningSBApplication.h"

#import "SPMediaKeyTap.h"
#import "BSVolumeWindowController.h"
#import "BSVolumeControlProtocol.h"

#import "BSBrowserExtensionsController.h"
#import "BSWebTabAdapter.h"
#import "BSNativeAppTabsController.h"

#import "Beardie-Swift.h"

#define VOLUME_RELAXING_TIMEOUT             2 //seconds

NSString *const InUpdatingStrategiesState = @"InUpdatingStrategiesState";

typedef enum{

    SwitchPlayerNext = 1,
    SwitchPlayerPrevious

} SwitchPlayerDirectionType;

BOOL accessibilityApiEnabled = NO;

@implementation AppDelegate {
    
    NSUInteger  statusMenuCount;
    
    NSMutableArray *playingTabs;

    NSWindowController *_preferencesWindowController;
    
    NSMutableSet    *openedWindows;
    
    NSXPCConnection *_connectionToService;
    
    BSBrowserExtensionsController *_browserExtensionsController;
    BSNativeAppTabsController *_nativeAppTabsController;
    
    BOOL _AXAPIEnabled;
    
    NSDate *_volumeButtonLastPressed;
}



- (void)dealloc{

    [self removeSystemEventsCallback];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Application Delegates
/////////////////////////////////////////////////////////////////////////

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{

    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BeardedSpiceUserDefaults" ofType:@"plist"]];
    if (appDefaults)
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    // Create serial queue for user actions
    _workingQueue = dispatch_queue_create("com.beardedspice.working.serial", DISPATCH_QUEUE_SERIAL);
    _volumeButtonLastPressed = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefChanged:) name: BSStrategiesPreferencesNativeAppChangedNoticiation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefChanged:) name: GeneralPreferencesAutoPauseChangedNoticiation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefChanged:) name: GeneralPreferencesUsingAppleRemoteChangedNoticiation object:nil];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // Application notifications
    [self setupSystemEventsCallback];

    self.activeApp = [BSActiveTab new];

    // setup default media strategy
    MediaStrategyRegistry *registry = [MediaStrategyRegistry singleton];
    [registry setUserDefaults:BeardedSpiceActiveControllers];

    [self shortcutsBind];
    [self newConnectionToControlService];

    self.inUpdatingStrategiesState = NO;
    
#if !DEBUG_STRATEGY
    /* Check for strategy updates from the master github repo */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceUpdateAtLaunch])
        [self checkForUpdates:self];
#endif
}

- (void)awakeFromNib
{
    [BSSharedResources initLoggerFor:BS_BUNDLE_ID];

    UIController.statusBarMenu = [[StatusBarMenu alloc] init:statusMenu];

    // Get initial count of menu items
    statusMenuCount = statusMenu.itemArray.count;

    // check accessibility enabled
    [self checkAccessibilityTrusted];

    [self resetStatusMenu:0];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    _nativeAppTabsController = BSNativeAppTabsController.singleton;
    _browserExtensionsController = BSBrowserExtensionsController.singleton;
    [_browserExtensionsController start];
    
    [self firstRunInstall];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{

    [self openPreferences:self];
    MASPreferencesWindowController *prefWin = (MASPreferencesWindowController *)(self.preferencesWindowController);
    [prefWin selectControllerWithIdentifier:StrategiesPreferencesViewController];
    [(BSStrategiesPreferencesViewController *)prefWin.selectedViewController importStrategyWithPath:filename];
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{
    
    DDLogInfo(@"App should terminate request.");
    
    static BOOL readyToTerminate = NO;
    
    if (readyToTerminate) {
        return NSTerminateNow;
    }
    dispatch_block_t exitBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            readyToTerminate = YES;
            [NSApp terminate:self];
            DDLogInfo(@"App ready for terminating.");
        });
        
    };
    
    dispatch_block_t stopControllerService = ^{
        if (self->_connectionToService) {
            [[self->_connectionToService remoteObjectProxy] prepareForClosingConnectionWithCompletion:^{
                [self->_connectionToService invalidate];
                exitBlock();
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COMMAND_EXEC_TIMEOUT * NSEC_PER_SEC)), self->_workingQueue, ^{
                [self->_connectionToService invalidate];
                exitBlock();
            });
        }
        else {
            exitBlock();
        }
    };
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        
        //--------------------- Stop Services ---------------------------
        BSStrategyWebSocketServer *server = self->_browserExtensionsController.webSocketServer;
        if (server.started) {
            
            [server stopWithComletion:^{
                stopControllerService();
            }];
        }
        else {
            stopControllerService();
        }
        
    });
    
    return NSTerminateCancel;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
 
    if (NSApp.activationPolicy != NSApplicationActivationPolicyAccessory) {
        return YES;
    }
    [UIController.statusBarMenu open];
    
    return NO;
}

- (void)firstRunInstall {
    if (accessibilityApiEnabled && [[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceFirstRun]) {
        
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSAlertStyleInformational;
        alert.messageText = BSLocalizedString(@"fistrun-open-preference-title", @"");
        alert.informativeText = BSLocalizedString(@"fistrun-open-preference-text", @"");
        [alert addButtonWithTitle:BSLocalizedString(@"fistrun-open-preferences-button-title", @"Button title")];
        
        [alert addButtonWithTitle:BSLocalizedString(@"cancel-button-title", @"Button title")];
        
        [UIController windowWillBeVisible:alert completion:^{
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                [self openPreferences:self];
                [(BSPreferencesWindowController *)self.preferencesWindowController selectControllerWithIdentifier:GeneralPreferencesViewController.className];
            };
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BeardedSpiceFirstRun];
            [UIController removeWindow:alert];

        }];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BeardieBrowserExtensionsFirstRun]) {
        //when `first run` operations completed
        dispatch_block_t completion = ^(){[[NSUserDefaults standardUserDefaults] setBool:NO forKey:BeardieBrowserExtensionsFirstRun];};
        
        dispatch_async(_workingQueue, ^{
            [self->_browserExtensionsController firstRunPerformWithCompletion:completion];
        });
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Delegate methods
/////////////////////////////////////////////////////////////////////////

- (void)menuNeedsUpdate:(NSMenu *)menu{
    ASSIGN_WEAK(self);
    dispatch_async(_workingQueue, ^{
        ASSIGN_STRONG(self);
        [USE_STRONG(self) autoSelectTabWithForceFocused:NO];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [USE_STRONG(self) setStatusMenuItemsStatus];
        });
    });
}

- (void)menuDidClose:(NSMenu *)menu {
    DDLogDebug(@"menuDidClose");
    [UIController.statusBarMenu didClose];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
    if ([kBSTrackNameIdentifier isEqualToString:notification.identifier]) {
        [self activatePlayingTab];
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

- (BOOL)inUpdatingStrategiesState {
    return [[NSUserDefaults standardUserDefaults] boolForKey:InUpdatingStrategiesState];
}
- (void)setInUpdatingStrategiesState:(BOOL)inUpdatingStrategiesState {
    [[NSUserDefaults standardUserDefaults] setBool:inUpdatingStrategiesState forKey:InUpdatingStrategiesState];
}
/////////////////////////////////////////////////////////////////////////
#pragma mark BeardedSpiceHostAppProtocol methods
/////////////////////////////////////////////////////////////////////////

- (void)playPauseToggle {
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:YES];
        [sself.activeApp toggle];
    });
}
- (void)nextTrack {
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp next];
    });
}

- (void)previousTrack {
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp previous];
    });
}

- (void)favorite {
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp favorite];
    });
}

- (void)activeTab {
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself refreshTabs:self];
        [sself setActiveTabShortcut];
    });
}

- (void)notification{
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp showNotificationNowUsingFallback:YES];
    });
}

- (void)activatePlayingTab{
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp activatePlayingTab];
    });
}

- (void)playerNext{
    [self switchPlayerWithDirection:SwitchPlayerNext];
}

- (void)playerPrevious{
    [self switchPlayerWithDirection:SwitchPlayerPrevious];
}

- (void)volumeUp{
    
    __weak typeof(self) wself = self;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceCustomVolumeControl]) {
        
        dispatch_async(_workingQueue, ^{
            
            __strong typeof(wself) sself = self;
            [sself autoSelectTabForVolumeButtons];
            BSVolumeControlResult result = BSVolumeControlNotSupported;
            if ((result = [sself.activeApp volumeUp]) == BSVolumeControlNotSupported
                ) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(wself) sself = self;
                    [sself pressKey:NX_KEYTYPE_SOUND_UP];
                });
            }
            else {
                
                BSVWType vwType = [self convertVolumeResult:(BSVolumeControlResult)result];
                [[BSVolumeWindowController singleton] showWithType:vwType title:sself.activeApp.displayName];
            }
        });
    }
    else
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wself) sself = self;
            [sself pressKey:NX_KEYTYPE_SOUND_UP];
        });
}

- (void)volumeDown{
    
    __weak typeof(self) wself = self;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceCustomVolumeControl]) {
        
        dispatch_async(_workingQueue, ^{
            
            __strong typeof(wself) sself = self;
            [sself autoSelectTabForVolumeButtons];
            BSVolumeControlResult result = BSVolumeControlNotSupported;
            if (
                (result = [sself.activeApp volumeDown]) == BSVolumeControlNotSupported
                ) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(wself) sself = self;
                    [sself pressKey:NX_KEYTYPE_SOUND_DOWN];
                });
            }
            else {
                
                BSVWType vwType = [self convertVolumeResult:(BSVolumeControlResult)result];
                [[BSVolumeWindowController singleton] showWithType:vwType title:sself.activeApp.displayName];
            }
        });
    }
    else
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wself) sself = self;
            [sself pressKey:NX_KEYTYPE_SOUND_DOWN];
        });
}

- (void)volumeMute{
    
    __weak typeof(self) wself = self;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceCustomVolumeControl]) {
        
        dispatch_async(_workingQueue, ^{
            
            __strong typeof(wself) sself = self;
            [sself autoSelectTabForVolumeButtons];
            BSVolumeControlResult result = BSVolumeControlNotSupported;
            if (
                (result = [sself.activeApp volumeMute]) == BSVolumeControlNotSupported
                ) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(wself) sself = self;
                    [sself pressKey:NX_KEYTYPE_MUTE];
                });
            }
            else {
                
                BSVWType vwType = [self convertVolumeResult:(BSVolumeControlResult)result];
                [[BSVolumeWindowController singleton] showWithType:vwType title:sself.activeApp.displayName];
            }
        });
    }
    else
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wself) sself = self;
            [sself pressKey:NX_KEYTYPE_MUTE];
        });
}

- (void)headphoneUnplug{
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself.activeApp pauseActiveTab];
    });
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

- (IBAction)checkForUpdates:(id)sender
{
    // MainMenu.xib has this menu item tag set as 256
    NSMenuItem *item = [statusMenu itemWithTag:256];
    // quietly exit because this shouldn't have happened...
    if (!item)
        return;
    
    self.inUpdatingStrategiesState = YES;
    statusMenu.autoenablesItems = NO;
    item.title = BSLocalizedString(@"Checking...", @"Menu Titles");
    
    BOOL checkFromMenu = (sender != self);
    ASSIGN_WEAK(self);
    [BSStrategyVersionManager.singleton updateStrategiesWithCompletion:^(NSArray<NSString *> *updatedNames, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ASSIGN_STRONG(self);
            if (error && checkFromMenu) {
                //TODO: display ALERT with error
            }
            else {
                NSString *message = [NSString stringWithFormat:BSLocalizedString(@"There were %u compatibility updates.", @"Notification Titles"), updatedNames.count];
                
                if (updatedNames.count){
//                    dispatch_async(USE_STRONG(self)->_workingQueue, ^{
//                        [USE_STRONG(self) refreshTabs:nil];
//                    })
                    [USE_STRONG(self) sendUpdateNotificationWithString:message];
                }
                else if (checkFromMenu) {
                    [USE_STRONG(self) sendUpdateNotificationWithString:message];
                }
                
            }
            
            item.title = BSLocalizedString(@"Check for Compatibility Updates", @"Menu Titles");
            self.inUpdatingStrategiesState = NO;
        });
    }];
}

- (IBAction)openPreferences:(id)sender
{
    [UIController windowWillBeVisible:self.preferencesWindowController.window completion:^{
        [self.preferencesWindowController showWindow:self];
    }];
}

- (IBAction)clickAboutFromStatusMenu:(id)sender {
    [UIController windowWillBeVisible:NSApp completion:^{
        [NSApp orderFrontStandardAboutPanel:sender];
        [UIController windowWillBeVisible:NSApp.windows.lastObject completion:^{
            [UIController removeWindow:NSApp];
        }];
    }];
}

- (IBAction)exitApp:(id)sender
{
    [NSApp terminate: nil];
}

- (void)updateActiveTabFromMenuItem:(id) sender
{
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself.activeApp updateActiveTab:[sender representedObject]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [wself setStatusMenuItemsStatus];
        });
    });
}

/////////////////////////////////////////////////////////////////////////
#pragma mark System Key Press Methods
/////////////////////////////////////////////////////////////////////////

- (void)pressKey:(NSUInteger)keytype {
    [self keyEvent:keytype state:0xA];  // key down
    [self keyEvent:keytype state:0xB];  // key up
}

- (void)keyEvent:(NSUInteger)keytype state:(NSUInteger)state {
    NSEvent *event = [NSEvent otherEventWithType:NSEventTypeSystemDefined
                                        location:NSZeroPoint
                                   modifierFlags:(state << 2)
                                       timestamp:0
                                    windowNumber:0
                                         context:nil
                                         subtype:0x8
                                           data1:(keytype << 16) | (state << 8)
                                           data2:SPPassthroughEventData2Value];

    CGEventPost(0, [event CGEvent]);
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods
/////////////////////////////////////////////////////////////////////////

- (BOOL)setActiveTabShortcut{

    @try {
        NSArray <TabAdapter *> *tabs = _browserExtensionsController.webSocketServer.tabs;
        tabs = [tabs arrayByAddingObjectsFromArray:_nativeAppTabsController.tabs];

        for (TabAdapter *tab in tabs) {
            if (tab.frontmost) {
                return [_activeApp updateActiveTab:tab];
            }
        }

        return NO;
    } @catch (NSException *exception) {
        DDLogError(@"Exception occured: %@", exception);
    }
}


-(BOOL)setStatusMenuItemsStatus{

    @autoreleasepool {
        NSInteger count = statusMenu.itemArray.count;
        for (int i = 0; i < (count - statusMenuCount); i++) {

            NSMenuItem *item = [statusMenu itemAtIndex:i];
            TabAdapter *tab = [item representedObject];
            BOOL isEqual = [_activeApp hasEqualTabAdapter:tab];

            [item setState:(isEqual ? NSControlStateValueOn : NSControlStateValueOff)];
        }

        return NO;
    }
}

// must be invoked not on main queue
- (void)refreshTabs:(id) sender
{
    DDLogDebug(@"Refreshing tabs...");
    __weak typeof(self) wself = self;
    @autoreleasepool {
        
        NSMutableArray *newItems = [NSMutableArray array];
        
        playingTabs = [NSMutableArray array];
        
        if (accessibilityApiEnabled) {
            
            NSMutableArray <TabAdapter *> *tabs = [NSMutableArray new];
            [tabs addObjectsFromArray:_browserExtensionsController.webSocketServer.tabs];
            [tabs addObjectsFromArray:_nativeAppTabsController.tabs];
            
            for (TabAdapter *tab in tabs) {
                @try {
                    NSMenuItem *menuItem = [[NSMenuItem alloc]
                                            initWithTitle:[tab.title trimToLength:40]
                                            action:@selector(updateActiveTabFromMenuItem:)
                                            keyEquivalent:@""];
                    if (menuItem) {
                        
                        [newItems addObject:menuItem];
                        [menuItem setRepresentedObject:tab];
                        
                        if ([tab isPlaying])
                            [playingTabs addObject:tab];
                    }
                } @catch (NSException *exception) {
                    DDLogError(@"Exception occured: %@", exception);
                }
            }
            if (![tabs containsObject:_activeApp.activeTab]) {
                _activeApp.activeTab = nil;
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [wself resetStatusMenu:newItems.count];
            
            if (newItems.count) {
                for (NSMenuItem *item in [newItems reverseObjectEnumerator]) {
                    [self->statusMenu insertItem:item atIndex:0];
                }
            }
        });
    }
}

// Must be invoked in workingQueue
- (void)autoSelectTabWithForceFocused:(BOOL)forceFocused{

    [self refreshTabs:self];

    switch (playingTabs.count) {

        case 1:

            [_activeApp updateActiveTab:playingTabs[0]];
            break;

        default: // null or many

            // try to set active tab to focus
            if ((forceFocused || !_activeApp) && [self setActiveTabShortcut]) {
                return;
            }

            if (_activeApp.activeTab == nil) {
                //try to set active tab to first item of menu
                TabAdapter *tab = [[statusMenu itemAtIndex:0] representedObject];
                if (tab)
                    [_activeApp updateActiveTab:tab];
            }
            break;
    }
}

- (void)checkAccessibilityTrusted{

    NSDictionary *options = @{CFBridgingRelease(kAXTrustedCheckOptionPrompt): @(YES)};
    accessibilityApiEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef _Nullable)(options));
    DDLogInfo(@"AccessibilityApiEnabled %@", (accessibilityApiEnabled ? @"YES":@"NO"));

    if (!accessibilityApiEnabled) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COMMAND_EXEC_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkAXAPIEnabled];
        });
    }
}

- (void)checkAXAPIEnabled{

    _AXAPIEnabled = AXIsProcessTrusted();
    DDLogInfo(@"AXAPIEnabled %@", (_AXAPIEnabled ? @"YES":@"NO"));
    if (_AXAPIEnabled){
        NSAlert * alert = [NSAlert new];
        alert.alertStyle = NSAlertStyleCritical;
        alert.informativeText = BSLocalizedString(@"universal-access-granted-dialog-text", @"Explanation that we need to restart app");
        alert.messageText = BSLocalizedString(@"universal-access-granted-dialog-title", @"Title that we need to restart app");
        [alert addButtonWithTitle:BSLocalizedString(@"universal-access-granted-dialog-restart-button-title", @"Restart button")];
        [alert addButtonWithTitle:BSLocalizedString(@"cancel-button-title", @"")];

        [UIController windowWillBeVisible:alert completion:^{
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                [self restartApp];
            }
            [UIController removeWindow:alert];
        }];
    }
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COMMAND_EXEC_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkAXAPIEnabled];
        });
    }
}

- (void)restartApp {
    static NSTask *_watchdog;
    
    NSString *appPath = [[NSBundle mainBundle] builtInPlugInsPath];

    pid_t pid = getpid();
    NSString *thePid = [NSString stringWithFormat:@"%d", pid];
    _watchdog = [NSTask launchedTaskWithLaunchPath:[appPath stringByAppendingPathComponent:BS_RESTARTER_NAME]
                                                arguments:@[[[NSBundle mainBundle] bundlePath], thePid]];
    
    DDLogInfo(@"(AAMaintenanceProcedures) Watchdog started.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSApplication sharedApplication] terminate:self];
    });

}

- (void)setupSystemEventsCallback
{
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(receiveSleepNote:)
     name: NSWorkspaceWillSleepNotification object: NULL];

    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(switchUserHandler:)
     name:NSWorkspaceSessionDidResignActiveNotification
     object:nil];
}

- (void)removeSystemEventsCallback{

    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        NSViewController *generalViewController = [GeneralPreferencesViewController new];
        NSViewController *shortcutsViewController = [ShortcutsPreferencesViewController new];
        NSViewController *strategiesViewController = [BSStrategiesPreferencesViewController new];
        NSArray *controllers = @[generalViewController, shortcutsViewController, strategiesViewController];

        NSString *title = BSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[BSPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
        
        if (@available(macOS 11.0, *)) {
            _preferencesWindowController.window.toolbarStyle = NSWindowToolbarStyleExpanded;
        }
        
    }
    return _preferencesWindowController;
}


- (void)switchPlayerWithDirection:(SwitchPlayerDirectionType)direction {

    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        @autoreleasepool {

            [wself autoSelectTabWithForceFocused:YES];

            NSUInteger size = self->statusMenu.itemArray.count - self->statusMenuCount;
            if (size < 2) {
                return;
            }

            TabAdapter *tab = [[self->statusMenu itemAtIndex:0] representedObject];
            TabAdapter *prevTab = [[self->statusMenu itemAtIndex:(size - 1)] representedObject];
            TabAdapter *nextTab = [[self->statusMenu itemAtIndex:1] representedObject];

            for (int i = 0; i < size; i++) {
                if ([wself.activeApp hasEqualTabAdapter:tab]) {
                    if (direction == SwitchPlayerNext) {
                        [wself.activeApp updateActiveTab:nextTab];
                    } else {
                        [wself.activeApp updateActiveTab:prevTab];
                    }

//                    [wself.activeApp activateTab];

                    NSUserNotification *notification = [NSUserNotification new];
                    notification.identifier = @"BSSwitchPlayerNotification";
                    notification.title = [wself.activeApp displayName];
                    notification.informativeText = [wself.activeApp title];

                    NSUserNotificationCenter *notifCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
                    [notifCenter removeDeliveredNotification:notification];
                    [notifCenter deliverNotification:notification];

                    return;
                }
                prevTab = tab;
                tab = nextTab;
                nextTab = (i < (size - 2)) ? [[self->statusMenu itemAtIndex:(i + 2)] representedObject] : [[self->statusMenu itemAtIndex:0] representedObject];
            }
        }
    });
}

- (void)resetStatusMenu:(NSInteger)menuItemCount{

    NSInteger count = statusMenu.itemArray.count;
    for (int i = 0; i < (count - statusMenuCount); i++) {
        [statusMenu removeItemAtIndex:0];
    }

    if (!menuItemCount) {
        NSMenuItem *item = nil;
        if (accessibilityApiEnabled) {
             item = [statusMenu insertItemWithTitle:BSLocalizedString(@"No applicable tabs open", @"Title on empty menu")
                                                        action:nil
                                                 keyEquivalent:@""
                                                       atIndex:0];
        }
        else if (_AXAPIEnabled){

            item = [statusMenu insertItemWithTitle:BSLocalizedString(@"menu-need-restart-title", @"Title on empty menu")
                                                        action:nil
                                                 keyEquivalent:@""
                                                       atIndex:0];
        }
        else{

            item = [statusMenu insertItemWithTitle:BSLocalizedString(@"menu-no-access-title", @"Title on empty menu")
                                                        action:nil
                                                 keyEquivalent:@""
                                                       atIndex:0];
        }
        [item setEnabled:NO];
        [item setEnabled:NO];
    }


}

- (void)sendUpdateNotificationWithString:(NSString *)message
{
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = BSLocalizedString(@"Compatibility Updates", @"Notification Titles");
    notification.subtitle = message;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (BSVWType)convertVolumeResult:(BSVolumeControlResult)volumeResult {

    BSVWType result = BSVWUnavailable;
    
    switch (volumeResult) {
            
            case BSVolumeControlUp:
            result = BSVWUp;
            break;

            case BSVolumeControlDown:
            result = BSVWDown;
            break;
            
            case BSVolumeControlMute:
            result = BSVWMute;
            break;
            
            case BSVolumeControlUnmute:
            result = BSVWUnmute;
            break;
            
        default:
            break;
    }
    
    return result;
}

- (void)autoSelectTabForVolumeButtons {
    
    if ([_volumeButtonLastPressed timeIntervalSinceNow] * -1 >= VOLUME_RELAXING_TIMEOUT) {
        [self autoSelectTabWithForceFocused:NO];
    }
    _volumeButtonLastPressed = [NSDate date];
}
/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications methods
/////////////////////////////////////////////////////////////////////////

- (void)receiveSleepNote:(NSNotification *)note
{
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        [wself.activeApp pauseActiveTab];
    });
}

- (void) switchUserHandler:(NSNotification*) notification
{
    __weak typeof(self) wself = self;
    dispatch_async(_workingQueue, ^{
        [wself.activeApp pauseActiveTab];
    });
}

- (void) prefChanged:(NSNotification*) notification{

    NSString *name = notification.name;

    if ([name isEqualToString:GeneralPreferencesAutoPauseChangedNoticiation]) {

        [self setHeadphonesListener];
    }
    else if ([name isEqualToString:GeneralPreferencesUsingAppleRemoteChangedNoticiation]) {

        [self setAppleRemotes];
    }
    else if ([name isEqualToString:BSStrategiesPreferencesNativeAppChangedNoticiation])
        [self refreshKeyTapBlackList];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Shortcuts binding
/////////////////////////////////////////////////////////////////////////
- (void)shortcutsBind{

//    NSDictionary *options = @{NSValueTransformerNameBindingOption: NSKeyedUnarchiveFromDataTransformerName};
    NSDictionary *options = @{};

    [self bind:BeardedSpicePlayPauseShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpicePlayPauseShortcut]
       options:options];

    [self bind:BeardedSpiceNextTrackShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpiceNextTrackShortcut]
       options:options];

    [self bind:BeardedSpicePreviousTrackShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpicePreviousTrackShortcut]
       options:options];

    [self bind:BeardedSpiceActiveTabShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpiceActiveTabShortcut]
       options:options];

    [self bind:BeardedSpiceFavoriteShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpiceFavoriteShortcut]
       options:options];

    [self bind:BeardedSpiceNotificationShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpiceNotificationShortcut]
       options:options];

    [self bind:BeardedSpiceActivatePlayingTabShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpiceActivatePlayingTabShortcut]
       options:options];

    [self bind:BeardedSpiceActivatePlayingTabShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpiceActivatePlayingTabShortcut]
       options:options];

    [self bind:BeardedSpicePlayerNextShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpicePlayerNextShortcut]
       options:options];

    [self bind:BeardedSpicePlayerPreviousShortcut
      toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:[@"values." stringByAppendingString:BeardedSpicePlayerPreviousShortcut]
       options:options];
}

- (id)valueForUndefinedKey:(NSString *)key{

    return nil;
}

- (void)setBeardedSpicePlayPauseShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpicePlayPauseShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceNextTrackShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceNextTrackShortcut: shortcut}];
    }
}
- (void)setBeardedSpicePreviousTrackShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpicePreviousTrackShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceActiveTabShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceActiveTabShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceFavoriteShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceFavoriteShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceNotificationShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceNotificationShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceActivatePlayingTabShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceActivatePlayingTabShortcut: shortcut}];
    }
}
- (void)setBeardedSpicePlayerNextShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpicePlayerNextShortcut: shortcut}];
    }
}
- (void)setBeardedSpicePlayerPreviousShortcut:(id)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpicePlayerPreviousShortcut: shortcut}];
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Controller Service methods
/////////////////////////////////////////////////////////////////////////

- (BOOL)newConnectionToControlService{

    if (_connectionToService) {
        [_connectionToService invalidate];
        _connectionToService = nil;
    }
     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:BS_CONTROLLER_BUNDLE_ID];
     _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(BeardedSpiceControllersProtocol)];

    _connectionToService.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(BeardedSpiceHostAppProtocol)];
    _connectionToService.exportedObject = self;

    id __weak wSelf = self;
    _connectionToService.interruptionHandler = ^{
        [wSelf resetConnectionToControlService];
    };

    if (_connectionToService) {

        [_connectionToService resume];
        [self resetConnectionToControlService];

        return YES;
    }

    return NO;
}

- (void)resetConnectionToControlService{

    [self resetShortcutsToControlService];
    [self refreshKeyTapBlackList];
    [self setHeadphonesListener];
    [self setAppleRemotes];
}

- (void)resetShortcutsToControlService{

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:9];

    NSData *shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpicePlayPauseShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpicePlayPauseShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceNextTrackShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpiceNextTrackShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpicePreviousTrackShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpicePreviousTrackShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceActiveTabShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpiceActiveTabShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceFavoriteShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpiceFavoriteShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceNotificationShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpiceNotificationShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceActivatePlayingTabShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpiceActivatePlayingTabShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpicePlayerNextShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpicePlayerNextShortcut];
    }

    shortcut  = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpicePlayerPreviousShortcut];
    if (shortcut) {
        [dict setObject:shortcut forKey:BeardedSpicePlayerPreviousShortcut];
    }

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:dict];
    }
}

- (void)refreshKeyTapBlackList{

    NSMutableArray *keyTapBlackList = [NSMutableArray arrayWithCapacity:5];

    for (Class theClass in [NativeAppTabsRegistry.singleton enabledNativeAppClasses]) {
        [keyTapBlackList addObject:[theClass bundleId]];
    }
    [keyTapBlackList addObject:[[NSBundle mainBundle] bundleIdentifier]];

    if (_connectionToService) {

        [[_connectionToService remoteObjectProxy] setMediaKeysSupportedApps:keyTapBlackList];
    }
    DDLogInfo(@"Refresh Key Tab Black List.");
}

- (void)setHeadphonesListener{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setPhoneUnplugActionEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceRemoveHeadphonesAutopause]];
    }
}

- (void)setAppleRemotes{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setUsingAppleRemoteEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceUsingAppleRemote]];
    }
}

@end
