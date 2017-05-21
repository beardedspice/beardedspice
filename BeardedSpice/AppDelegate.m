//
//  AppDelegate.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#include <IOKit/hidsystem/ev_keymap.h>

#import "AppDelegate.h"

#import "ChromeTabAdapter.h"
#import "SafariTabAdapter.h"
#import "NativeAppTabAdapter.h"

#import "BSSharedDefaults.h"
#import "BeardedSpiceControllersProtocol.h"

#import "BSPreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"
#import "ShortcutsPreferencesViewController.h"
#import "NSString+Utils.h"
#import "BSTimeout.h"

#import "BSActiveTab.h"

#import "BSStrategyCache.h"
#import "BSTrack.h"
#import "BSStrategyVersionManager.h"
#import "BSCustomStrategyManager.h"

#import "runningSBApplication.h"

/**
 Timeout for command of the user iteraction.
 */
#define COMMAND_EXEC_TIMEOUT    10.0

typedef enum{

    SwithPlayerNext = 1,
    SwithPlayerPrevious

} SwithPlayerDirectionType;

BOOL accessibilityApiEnabled = NO;

@implementation AppDelegate


- (void)dealloc{

    [self removeSystemEventsCallback];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Application Delegates
/////////////////////////////////////////////////////////////////////////

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
//    // Insert code here to initialize your application
//    // Register defaults for the whitelist of apps that want to use media keys
//    NSMutableDictionary *registeredDefaults = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                        [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
//                        nil];

    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BeardedSpiceUserDefaults" ofType:@"plist"]];
    if (appDefaults)
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    // Create serial queue for user actions
    workingQueue = dispatch_queue_create("com.beardedspice.working.serial", DISPATCH_QUEUE_SERIAL);

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceThemeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalPrefChanged:) name: GeneralPreferencesNativeAppChangedNoticiation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalPrefChanged:) name: GeneralPreferencesAutoPauseChangedNoticiation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalPrefChanged:) name: GeneralPreferencesUsingAppleRemoteChangedNoticiation object:nil];

    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(receivedWillCloseWindow:) name: NSWindowWillCloseNotification object:nil];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // Application notifications
    [self setupSystemEventsCallback];

    BSStrategyCache *strategyCache = [BSStrategyCache new];
    [strategyCache loadStrategies];

    self.versionManager = [[BSStrategyVersionManager alloc] initWithStrategyCache:strategyCache];

    self.activeApp = [BSActiveTab new];

    // setup default media strategy
    MediaStrategyRegistry *registry = [MediaStrategyRegistry singleton];
    [registry setUserDefaults:BeardedSpiceActiveControllers strategyCache:strategyCache];

    // setup native apps
    nativeAppRegistry = [NativeAppTabRegistry singleton];
    [nativeAppRegistry setUserDefaultsKey:BeardedSpiceActiveNativeAppControllers];

    nativeApps = [NSMutableArray array];

    [self shortcutsBind];
    [self newConnectionToControlService];

#if !DEBUG_STRATEGY
    /* Check for strategy updates from the master github repo */
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceUpdateAtLaunch])
        [self checkForUpdates:self];
#endif
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24.0];
    [statusItem setMenu:statusMenu];

    [self interfaceThemeChanged:nil];
    [statusItem setHighlightMode:YES];

    // Get initial count of menu items
    statusMenuCount = statusMenu.itemArray.count;

    // check accessibility enabled
    [self checkAccessibilityTrusted];

    [self resetStatusMenu];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{

    [[BSCustomStrategyManager singleton] importFromPath:filename];
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] prepareForClosingConnectionWithCompletion:^{
            [_connectionToService invalidate];
            [sender replyToApplicationShouldTerminate:YES];
        }];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COMMAND_EXEC_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_connectionToService invalidate];
            [sender replyToApplicationShouldTerminate:YES];
        });
        return NSTerminateLater;
    }
    return NSTerminateNow;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Delegate methods
/////////////////////////////////////////////////////////////////////////

- (void)menuNeedsUpdate:(NSMenu *)menu{
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        [wself autoSelectTabWithForceFocused:NO];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [wself setStatusMenuItemsStatus];
        });
    });
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
#pragma mark BeardedSpiceHostAppProtocol methods
/////////////////////////////////////////////////////////////////////////

- (void)playPauseToggle {
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:YES];
        [sself.activeApp toggle];
    });
}
- (void)nextTrack {
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp next];
    });
}

- (void)previousTrack {
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp previous];
    });
}

- (void)favorite {
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp favorite];
    });
}

#pragma mark -

- (void)activeTab {
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself refreshTabs:self];
        [sself setActiveTabShortcut];
    });
}

- (void)notification{
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp showNotificationUsingFallback:YES];
    });
}

- (void)activatePlayingTab{
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself autoSelectTabWithForceFocused:NO];
        [sself.activeApp activatePlayingTab];
    });
}

- (void)playerNext{
    [self switchPlayerWithDirection:SwithPlayerNext];
}

- (void)playerPrevious{
    [self switchPlayerWithDirection:SwithPlayerPrevious];
}

- (void)volumeUp{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(wself) sself = self;
        [sself pressKey:NX_KEYTYPE_SOUND_UP];
    });
}

- (void)volumeDown{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(wself) sself = self;
        [sself pressKey:NX_KEYTYPE_SOUND_DOWN];
    });
}

- (void)headphoneUnplug{
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
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

    statusMenu.autoenablesItems = NO;
    item.enabled = NO;
    item.title = NSLocalizedString(@"Checking...", @"Menu Titles");

    BOOL checkFromMenu = (sender != self);
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        __strong typeof(wself) sself = wself;

        NSUInteger updateCount = [sself.versionManager performSyncUpdateCheck];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"There were %u compatibility updates.", @"Notification Titles"), updateCount];
        
        if (updateCount == 0){
            if (checkFromMenu) {
                [sself sendUpdateNotificationWithString:message];
            }
        }
        else
        {
            [sself refreshTabs:nil];
            [sself sendUpdateNotificationWithString:message];
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            item.title = NSLocalizedString(@"Check for Compatibility Updates", @"Menu Titles");
            item.enabled = YES;
        });
    });
}

- (IBAction)openPreferences:(id)sender
{
    [self windowWillBeVisible:self.preferencesWindowController.window];
    [self.preferencesWindowController showWindow:self];
}

- (IBAction)exitApp:(id)sender
{
    [NSApp terminate: nil];
}

- (void)updateActiveTabFromMenuItem:(id) sender
{
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        __strong typeof(wself) sself = self;
        [sself.activeApp updateActiveTab:[sender representedObject]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [wself setStatusMenuItemsStatus];
            [wself.activeApp activateTab];
        });
    });
}

/////////////////////////////////////////////////////////////////////
#pragma mark Windows control methods
/////////////////////////////////////////////////////////////////////

-(void)windowWillBeVisible:(id)window{

    if (window == nil)
        return;

    @synchronized(openedWindows) {

        if (!openedWindows)
            openedWindows = [NSMutableSet set];

        if (!openedWindows.count) {
            [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
        }
        [self activateApp];
        [openedWindows addObject:window];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSApplication sharedApplication] arrangeInFront:self];
        });
    }
}

-(void)activateApp {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

-(void)removeWindow:(id)obj {

    if (obj == nil)
        return;

    @synchronized(openedWindows){

        [openedWindows removeObject:obj];
        if (![openedWindows count]){
            [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyAccessory];
        }
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark System Key Press Methods
/////////////////////////////////////////////////////////////////////////

- (void)pressKey:(NSUInteger)keytype {
    [self keyEvent:keytype state:0xA];  // key down
    [self keyEvent:keytype state:0xB];  // key up
}

- (void)keyEvent:(NSUInteger)keytype state:(NSUInteger)state {
    NSEvent *event = [NSEvent otherEventWithType:NSSystemDefined
                                        location:NSZeroPoint
                                   modifierFlags:(state << 2)
                                       timestamp:0
                                    windowNumber:0
                                         context:nil
                                         subtype:0x8
                                           data1:(keytype << 16) | (state << 8)
                                           data2:-1];

    CGEventPost(0, [event CGEvent]);
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods
/////////////////////////////////////////////////////////////////////////


-(runningSBApplication *)getRunningSBApplicationWithIdentifier:(NSString *)bundleIdentifier
{
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    if ([apps count] > 0) {
        NSRunningApplication *app = [apps firstObject];
        NSLog(@"App %@ is running %@", bundleIdentifier, app);
        return [[runningSBApplication alloc] initWithApplication:[SBApplication applicationWithProcessIdentifier:[app processIdentifier]] bundleIdentifier:bundleIdentifier];
    }
    return NULL;
}

- (void)refreshApplications:(BSTimeout *)timeout {

    if (timeout.reached) {
        return;
    }

    chromeApp = [self getRunningSBApplicationWithIdentifier:APPID_CHROME];
    if (timeout.reached) {
        return;
    }

    canaryApp = [self getRunningSBApplicationWithIdentifier:APPID_CANARY];
    if (timeout.reached) {
        return;
    }

    yandexBrowserApp = [self getRunningSBApplicationWithIdentifier:APPID_YANDEX];
    if (timeout.reached) {
        return;
    }

    chromiumApp = [self getRunningSBApplicationWithIdentifier:APPID_CHROMIUM];
    if (timeout.reached) {
        return;
    }

    vivaldiApp = [self getRunningSBApplicationWithIdentifier:APPID_VIVALDI];
    if (timeout.reached) {
        return;
    }
    safariApp = [self getRunningSBApplicationWithIdentifier:APPID_SAFARI];
    if (timeout.reached) {
        return;
    }

    safariTPApp = [self getRunningSBApplicationWithIdentifier:APPID_SAFARITP];
    if (timeout.reached) {
        return;
    }

    [nativeApps removeAllObjects];
    for (Class nativeApp in [nativeAppRegistry enabledNativeAppClasses]) {
        runningSBApplication *app =
            [self getRunningSBApplicationWithIdentifier:[nativeApp bundleId]];
        if (app) {
            [nativeApps addObject:app];
        }
        if (timeout.reached) {
            return;
        }
    }
}

- (BOOL)setActiveTabShortcutForChrome:(runningSBApplication *)app {
    ChromeApplication *chrome = (ChromeApplication *)app.sbApplication;
    // chromeApp.windows[0] is the front most window.
    ChromeWindow *chromeWindow = chrome.windows[0];

    // use 'get' to force a hard reference.
    return [_activeApp updateActiveTab:[ChromeTabAdapter initWithApplication:app andWindow:chromeWindow andTab:[chromeWindow activeTab]]];
}

- (BOOL)setActiveTabShortcutForSafari:(runningSBApplication *)app {
    SafariApplication *safari = (SafariApplication *)app.sbApplication;
    // is safari.windows[0] the frontmost?
    SafariWindow *safariWindow = safari.windows[0];

    // use 'get' to force a hard reference.
    return [_activeApp updateActiveTab:[SafariTabAdapter initWithApplication:app
                                                      andWindow:safariWindow
                                                         andTab:[safariWindow currentTab]]];
}

- (BOOL)setActiveTabShortcut{

    BOOL result = NO;
    if (chromeApp.frontmost) {
        result = [self setActiveTabShortcutForChrome:chromeApp];
    } else if (canaryApp.frontmost) {
        result = [self setActiveTabShortcutForChrome:canaryApp];
    } else if (yandexBrowserApp.frontmost) {
        result = [self setActiveTabShortcutForChrome:yandexBrowserApp];
    } else if (chromiumApp.frontmost) {
        result = [self setActiveTabShortcutForChrome:chromiumApp];
    }else if (vivaldiApp.frontmost) {
        result = [self setActiveTabShortcutForChrome:vivaldiApp];
    } else if (safariApp.frontmost) {
        result = [self setActiveTabShortcutForSafari:safariApp];
    } else if (safariTPApp.frontmost) {
        result = [self setActiveTabShortcutForSafari:safariTPApp];
    } else {

        for (runningSBApplication *app in nativeApps) {
            if (app.frontmost) {
                NativeAppTabAdapter *tab = [[nativeAppRegistry classForBundleId:app.bundleIdentifier] tabAdapterWithApplication:app];
                if (tab) {
                    result = [_activeApp updateActiveTab:tab];
                }
                break;
            }
        }
    }

    return result;
}

- (void)removeAllItems
{
    SafariTabKeys = [NSMutableSet set];

    menuItems = [NSMutableArray array];
    // reset playingTabs
    playingTabs = [NSMutableArray array];

}

-(BOOL)setStatusMenuItemsStatus{

    @autoreleasepool {
        NSInteger count = statusMenu.itemArray.count;
        for (int i = 0; i < (count - statusMenuCount); i++) {

            NSMenuItem *item = [statusMenu itemAtIndex:i];
            TabAdapter *tab = [item representedObject];
            BOOL isEqual = [_activeApp hasEqualTabAdapter:tab];

            [item setState:(isEqual ? NSOnState : NSOffState)];
        }

        return NO;
    }
}


- (NSArray *)refreshTabsForChrome:(runningSBApplication *)app timeout:(BSTimeout *)timeout {

    if (timeout.reached) {
        return @[];
    }

    NSMutableArray *items = [NSMutableArray array];
    @try {

        NSMenuItem *item = nil;
        ChromeApplication *chrome = (ChromeApplication *)app.sbApplication;
        if (chrome) {
            for (ChromeWindow *chromeWindow in [chrome.windows get]) {
                for (ChromeTab *chromeTab in [chromeWindow.tabs get]) {
                    item = [self addChromeStatusMenuItemFor:chromeTab andWindow:chromeWindow andApplication:app];
                    if (item) {
                        [items addObject:item];
                    }
                    if (timeout.reached) {
                        return items;
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error ferreshing tabs for \"%@\": %@", app.bundleIdentifier, exception.description);
    }

    return items;
}

- (NSArray *)refreshTabsForSafari:(runningSBApplication *)app timeout:(BSTimeout *)timeout {

    if (timeout.reached) {
        return @[];
    }

    NSMutableArray *items = [NSMutableArray array];
    @try {

        NSMenuItem *item;
        SafariApplication *safari = (SafariApplication *)app.sbApplication;
        if (safari) {
            for (SafariWindow *safariWindow in [safari.windows get]) {
                for (SafariTab *safariTab in [safariWindow.tabs get]) {
                    item = [self addSafariStatusMenuItemFor:safariTab andWindow:safariWindow andApplication:app];
                    if (item) {
                        [items addObject:item];
                    }
                    if (timeout.reached) {
                        return items;
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Error ferreshing tabs for \"%@\": %@", app.bundleIdentifier, exception.description);
    }

    return items;
}

- (NSArray *)refreshTabsForNativeApp:(runningSBApplication *)app class:(Class)theClass {

    NSMutableArray *items = [NSMutableArray array];
    if (app) {
        TabAdapter *tab = [theClass tabAdapterWithApplication:app];

        if (tab) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[tab.title trimToLength:40] action:@selector(updateActiveTabFromMenuItem:) keyEquivalent:@""];
            if (menuItem) {

                [items addObject:menuItem];
                [menuItem setRepresentedObject:tab];

                if ([tab respondsToSelector:@selector(isPlaying)] && [(NativeAppTabAdapter *)tab isPlaying])
                    [playingTabs addObject:tab];

                [_activeApp repairActiveTab:tab];
            }
        }
    }
    return items;
}

// must be invoked not on main queue
- (void)refreshTabs:(id) sender
{
    NSLog(@"Refreshing tabs...");
    __weak typeof(self) wself = self;
    @autoreleasepool {

        //hold activeTab object
        __unsafe_unretained TabAdapter *activeTabHolder = self.activeApp.activeTab;
        //hold tab list
        NSArray *_menuItems = menuItems;
        NSMutableArray *newItems = [NSMutableArray array];

        [self removeAllItems];

        if (accessibilityApiEnabled) {

            BSTimeout *timeout = [BSTimeout timeoutWithInterval:COMMAND_EXEC_TIMEOUT];
            [self refreshApplications:timeout];

            [newItems addObjectsFromArray:[self refreshTabsForChrome:chromeApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForChrome:canaryApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForChrome:yandexBrowserApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForChrome:chromiumApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForChrome:vivaldiApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForSafari:safariApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForSafari:safariTPApp timeout:timeout]];

            for (runningSBApplication *app in nativeApps) {

                if (timeout.reached) {
                    break;
                }

                [newItems addObjectsFromArray:[self refreshTabsForNativeApp:app class:[nativeAppRegistry classForBundleId:app.bundleIdentifier]]];
            }
        }

        //
        NSMutableArray *tabs = [[newItems valueForKey:@"representedObject"] mutableCopy];
        for (NSMenuItem *item in _menuItems) {

            NSUInteger index = [tabs indexOfObject:item.representedObject];
            if (index != NSNotFound) {
                [menuItems addObject:newItems[index]];
                [newItems removeObjectAtIndex:index];
                [tabs removeObjectAtIndex:index];
            }
        }
        [menuItems addObjectsFromArray:newItems];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [wself resetStatusMenu];

            if (menuItems.count) {
                for (NSMenuItem *item in menuItems) {
                    [statusMenu insertItem:item atIndex:0];
                }
            }
        });
        
        //  check activeTab
        //
        //  It is because if `repairActiveTab` call cannot change activeTab,
        //  then we lost active tab and we need reset it.
        // https://github.com/beardedspice/beardedspice/issues/612
        if (activeTabHolder == self.activeApp.activeTab) {
            self.activeApp.activeTab = nil;
        }

    }
}

-(NSMenuItem *)addChromeStatusMenuItemFor:(ChromeTab *)chromeTab andWindow:(ChromeWindow*)chromeWindow andApplication:(runningSBApplication *)application
{
    TabAdapter *tab = [ChromeTabAdapter initWithApplication:application andWindow:chromeWindow andTab:chromeTab];
    if (tab)
        return [self addStatusMenuItemFor:tab];

    return nil;
}


-(NSMenuItem *)addSafariStatusMenuItemFor:(SafariTab *)safariTab andWindow:(SafariWindow*)safariWindow andApplication:(runningSBApplication *)application
{
    TabAdapter *tab = [SafariTabAdapter initWithApplication:application
                                              andWindow:safariWindow
                                                 andTab:safariTab];
    if (tab) {

        //checking, that tab wasn't included in status menu.
        //We need it because Safari "pinned" tabs duplicated on each window. (Safari 9)

        NSString *key = tab.key;
        if ([NSString isNullOrEmpty:key]) {
            //key was not assigned, we think this is fake pinned tab.
            return nil;
        }

        if ([SafariTabKeys containsObject:key]) {

            return nil;
        }
        //-------------------------------------------

        NSMenuItem *item = [self addStatusMenuItemFor:tab];
        if (item) {
            [SafariTabKeys addObject:key];
            return item;
        }
    }

    return nil;
}

-(NSMenuItem *)addStatusMenuItemFor:(TabAdapter *)tab {

    MediaStrategyRegistry *registry = [MediaStrategyRegistry singleton];
    BSMediaStrategy *strategy = [registry getMediaStrategyForTab:tab];
    if (strategy) {

        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[tab.title trimToLength:40] action:@selector(updateActiveTabFromMenuItem:) keyEquivalent:@""];
        if (menuItem) {
            [menuItem setRepresentedObject:tab];

            // check playing status
            if ([strategy respondsToSelector:@selector(isPlaying:)] && [strategy isPlaying:tab])
                [playingTabs addObject:tab];

            [_activeApp repairActiveTab:tab];

            return menuItem;
        }
    }

    return nil;
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

    if (AXIsProcessTrustedWithOptions != NULL) {

        NSDictionary *options = @{CFBridgingRelease(kAXTrustedCheckOptionPrompt): @(YES)};
        accessibilityApiEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef _Nullable)(options));
        NSLog(@"AccessibilityApiEnabled %@", (accessibilityApiEnabled ? @"YES":@"NO"));
    }else{

        accessibilityApiEnabled = AXAPIEnabled();
        NSLog(@"AXAPIEnabled %@", (accessibilityApiEnabled ? @"YES":@"NO"));
    }

    if (!accessibilityApiEnabled) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COMMAND_EXEC_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkAXAPIEnabled];
        });
    }
}

- (void)checkAXAPIEnabled{

    _AXAPIEnabled = AXAPIEnabled();
    NSLog(@"AXAPIEnabled %@", (_AXAPIEnabled ? @"YES":@"NO"));
    if (_AXAPIEnabled){
        NSAlert * alert = [NSAlert new];
        alert.alertStyle = NSCriticalAlertStyle;
        alert.informativeText = NSLocalizedString(@"Once you enable access in System Preferences, you must restart BeardedSpice.", @"Explanation that we need to restart app");
        alert.messageText = NSLocalizedString(@"You must restart BeardedSpice.", @"Title that we need to restart app");
        [alert addButtonWithTitle:NSLocalizedString(@"Ok", @"Restart button")];

        [self windowWillBeVisible:alert];

        [alert runModal];

        [self removeWindow:alert];
    }
    else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(COMMAND_EXEC_TIMEOUT * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkAXAPIEnabled];
        });
    }
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
        NSArray *controllers = @[generalViewController, shortcutsViewController];

        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[BSPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}


- (void)switchPlayerWithDirection:(SwithPlayerDirectionType)direction {

    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        @autoreleasepool {

            [wself autoSelectTabWithForceFocused:NO];

            NSUInteger size = statusMenu.itemArray.count - statusMenuCount;
            if (size < 2) {
                return;
            }

            TabAdapter *tab = [[statusMenu itemAtIndex:0] representedObject];
            TabAdapter *prevTab = [[statusMenu itemAtIndex:(size - 1)] representedObject];
            TabAdapter *nextTab = [[statusMenu itemAtIndex:1] representedObject];

            for (int i = 0; i < size; i++) {
                if ([wself.activeApp hasEqualTabAdapter:tab]) {
                    if (direction == SwithPlayerNext) {
                        [wself.activeApp updateActiveTab:nextTab];
                    } else {
                        [wself.activeApp updateActiveTab:prevTab];
                    }

                    [wself.activeApp activateTab];

                    NSUserNotification *notification = [NSUserNotification new];
                    notification.title = [wself.activeApp displayName];
                    notification.informativeText = [wself.activeApp title];

                    NSUserNotificationCenter *notifCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
                    [notifCenter deliverNotification:notification];

                    return;
                }
                prevTab = tab;
                tab = nextTab;
                nextTab = (i < (size - 2)) ? [[statusMenu itemAtIndex:(i + 2)] representedObject] : [[statusMenu itemAtIndex:0] representedObject];
            }
        }
    });
}

- (void)resetStatusMenu{

    NSInteger count = statusMenu.itemArray.count;
    for (int i = 0; i < (count - statusMenuCount); i++) {
        [statusMenu removeItemAtIndex:0];
    }

    if (!menuItems.count) {
        NSMenuItem *item = nil;
        if (accessibilityApiEnabled) {
             item = [statusMenu insertItemWithTitle:NSLocalizedString(@"No applicable tabs open", @"Title on empty menu")
                                                        action:nil
                                                 keyEquivalent:@""
                                                       atIndex:0];
        }
        else if (_AXAPIEnabled){

            item = [statusMenu insertItemWithTitle:NSLocalizedString(@"You must restart BeardedSpice", @"Title on empty menu")
                                                        action:nil
                                                 keyEquivalent:@""
                                                       atIndex:0];
        }
        else{

            item = [statusMenu insertItemWithTitle:NSLocalizedString(@"No access to control of the keyboard", @"Title on empty menu")
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
    notification.title = NSLocalizedString(@"Bearded Spice - Compatibility Updates", @"Notification Titles");
    notification.subtitle = message;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}


/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications methods
/////////////////////////////////////////////////////////////////////////

- (void)receivedWillCloseWindow:(NSNotification *)theNotification{
    NSWindow *window = theNotification.object;
    [self removeWindow:window];
}

- (void)receiveSleepNote:(NSNotification *)note
{
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        [wself.activeApp pauseActiveTab];
    });
}

- (void) switchUserHandler:(NSNotification*) notification
{
    __weak typeof(self) wself = self;
    dispatch_async(workingQueue, ^{
        [wself.activeApp pauseActiveTab];
    });
}

- (void) generalPrefChanged:(NSNotification*) notification{

    NSString *name = notification.name;

    if ([name isEqualToString:GeneralPreferencesAutoPauseChangedNoticiation]) {

        [self setHeadphonesListener];
    }
    else if ([name isEqualToString:GeneralPreferencesUsingAppleRemoteChangedNoticiation]) {

        [self setAppleRemotes];
    }
    else if ([name isEqualToString:GeneralPreferencesNativeAppChangedNoticiation])
        [self refreshKeyTapBlackList];
}

-(void)interfaceThemeChanged:(NSNotification *)notif
{
    @autoreleasepool {

        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
        id style = [dict objectForKey:@"AppleInterfaceStyle"];
        BOOL isDarkMode = ( style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"] );

        if (statusItem) {
            if (isDarkMode) {
                [statusItem setImage:[NSImage imageNamed:@"icon20x19-alt"]];
                [statusItem setAlternateImage:[NSImage imageNamed:@"icon20x19-alt"]];
            }
            else{
                [statusItem setImage:[NSImage imageNamed:@"icon20x19"]];
                [statusItem setAlternateImage:[NSImage imageNamed:@"icon20x19-alt"]];
            }
        }
    }
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

- (void)setBeardedSpicePlayPauseShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpicePlayPauseShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceNextTrackShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceNextTrackShortcut: shortcut}];
    }
}
- (void)setBeardedSpicePreviousTrackShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpicePreviousTrackShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceActiveTabShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceActiveTabShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceFavoriteShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceFavoriteShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceNotificationShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceNotificationShortcut: shortcut}];
    }
}
- (void)setBeardedSpiceActivatePlayingTabShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpiceActivatePlayingTabShortcut: shortcut}];
    }
}
- (void)setBeardedSpicePlayerNextShortcut:(NSData *)shortcut{

    if (_connectionToService) {
        [[_connectionToService remoteObjectProxy] setShortcuts:@{BeardedSpicePlayerNextShortcut: shortcut}];
    }
}
- (void)setBeardedSpicePlayerPreviousShortcut:(NSData *)shortcut{

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
     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"com.beardedspice.BeardedSpiceControllers"];
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

    for (Class theClass in [nativeAppRegistry enabledNativeAppClasses]) {
        [keyTapBlackList addObject:[theClass bundleId]];
    }
    [keyTapBlackList addObject:[[NSBundle mainBundle] bundleIdentifier]];

    if (_connectionToService) {

        [[_connectionToService remoteObjectProxy] setMediaKeysSupportedApps:keyTapBlackList];
    }
    NSLog(@"Refresh Key Tab Black List.");
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
