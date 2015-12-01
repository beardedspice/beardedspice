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

#import "BSStrategyVersionManager.h"

#import "runningSBApplication.h"

/// Because user defaults have good caching mechanism, we can use this macro.
#define ALWAYSSHOWNOTIFICATION  [[[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceAlwaysShowNotification] boolValue]

/**
 Timeout for command of the user iteraction.
 */
#define COMMAND_EXEC_TIMEOUT    5.0

/// Delay displaying notification after changing favorited status of the current track.
#define FAVORITED_DELAY         0.3

/// Delay displaying notification after pressing next/previous track.
#define CHANGE_TRACK_DELAY      2.0

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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
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
    workingQueue = dispatch_queue_create("WorkingQueue", DISPATCH_QUEUE_SERIAL);

    /* Check for strategy updates from the master github repo */
    BSStrategyVersionManager *versionManager = [BSStrategyVersionManager sharedVersionManager];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceUpdateAtLaunch])
        [versionManager performUpdateCheck];

    // Create serial queue for notification
    // We need queue because track info may contain image,
    // which retrieved from URL, this may cause blocking of the main thread.
    notificationQueue = dispatch_queue_create("NotificationQueue", DISPATCH_QUEUE_SERIAL);
    //

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceThemeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalPrefChanged:) name: GeneralPreferencesNativeAppChangedNoticiation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalPrefChanged:) name: GeneralPreferencesAutoPauseChangedNoticiation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generalPrefChanged:) name: GeneralPreferencesUsingAppleRemoteChangedNoticiation object:nil];

    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(receivedWillCloseWindow:) name: NSWindowWillCloseNotification object:nil];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // Application notifications
    [self setupSystemEventsCallback];

    // setup default media strategy
    mediaStrategyRegistry = [[MediaStrategyRegistry alloc] initWithUserDefaults:BeardedSpiceActiveControllers];

    // setup native apps
    nativeAppRegistry = [[NativeAppTabRegistry alloc]
        initWithUserDefaultsKey:BeardedSpiceActiveNativeAppControllers];

    nativeApps = [NSMutableArray array];

    [self shortcutsBind];
    [self newConnectionToControlService];
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

    dispatch_async(workingQueue, ^{

        [self autoSelectTabWithForceFocused:NO];
        dispatch_sync(dispatch_get_main_queue(), ^{

            [self setStatusMenuItemsStatus];
        });
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{

    return YES;
}


/////////////////////////////////////////////////////////////////////////
#pragma mark BeardedSpiceHostAppProtocol methods
/////////////////////////////////////////////////////////////////////////

- (void)playPauseToggle{

    dispatch_async(workingQueue, ^{

        [self autoSelectTabWithForceFocused:YES];
        if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {

            NativeAppTabAdapter *tab = (NativeAppTabAdapter *)activeTab;
            if ([tab respondsToSelector:@selector(toggle)]) {
                [tab toggle];
                if ([tab showNotifications] && ALWAYSSHOWNOTIFICATION &&
                    ![tab frontmost])
                    [self showNotification];
            }
        } else {

            BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
            if (strategy && ![NSString isNullOrEmpty:[strategy toggle]]) {
                [activeTab executeJavascript:[strategy toggle]];
                if (ALWAYSSHOWNOTIFICATION && ![activeTab frontmost]) {
                    [self showNotification];
                }
            }
        }
    });
}
- (void)nextTrack{

    dispatch_async(workingQueue, ^{

        [self autoSelectTabWithForceFocused:NO];
        if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {

            NativeAppTabAdapter *tab = (NativeAppTabAdapter *)activeTab;
            if ([tab respondsToSelector:@selector(next)]) {
                [tab next];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{

                                   if ([tab showNotifications] && ALWAYSSHOWNOTIFICATION &&
                                       ![tab frontmost])
                                       [self showNotification];
                               });
            }
        } else {

            BSMediaStrategy *strategy =[mediaStrategyRegistry getMediaStrategyForTab:activeTab];
            if (strategy && ![NSString isNullOrEmpty:[strategy next]]) {
                [activeTab executeJavascript:[strategy next]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{

                                   if (ALWAYSSHOWNOTIFICATION && ![activeTab frontmost]) {
                                       [self showNotification];
                                   }
                               });
            }
        }
    });
}

- (void)previousTrack{

    dispatch_async(workingQueue, ^{

        [self autoSelectTabWithForceFocused:NO];
        if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {

            NativeAppTabAdapter *tab = (NativeAppTabAdapter *)activeTab;
            if ([tab respondsToSelector:@selector(previous)]) {
                [tab previous];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{

                                   if ([tab showNotifications] && ALWAYSSHOWNOTIFICATION &&
                                       ![tab frontmost])
                                       [self showNotification];
                               });
            }
        } else {

            BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
            if (strategy && ![NSString isNullOrEmpty:[strategy previous]]) {
                [activeTab executeJavascript:[strategy previous]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{

                                   if (ALWAYSSHOWNOTIFICATION && ![activeTab frontmost]) {
                                       [self showNotification];
                                   }
                               });
            }
        }
    });
}

- (void)activeTab{

    dispatch_async(workingQueue, ^{

        [self refreshTabs:self];
        [self setActiveTabShortcut];
    });

}

- (void)favorite{
    dispatch_async(workingQueue, ^{

        [self autoSelectTabWithForceFocused:NO];

        if ([activeTab isKindOfClass:
             [NativeAppTabAdapter class]]) {

            NativeAppTabAdapter *tab =
            (NativeAppTabAdapter *)activeTab;
            if ([tab respondsToSelector:@selector(favorite)]) {
                [tab favorite];
                if ([[tab trackInfo] favorited]) {
                    [self showNotification];
                }
            }
        } else {

            BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
            if (strategy) {
                [activeTab
                 executeJavascript:[strategy favorite]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(FAVORITED_DELAY * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   @try {
                                       if ([[strategy trackInfo:activeTab] favorited])
                                           [self showNotification];
                                   }
                                   @catch (NSException *exception) {
                                       NSLog(@"(AppDelegate - setupFavoriteShortcutCallback) Error getting track info: %@.", [exception description]);
                                   }
                               });
            }
        }
    });
}

- (void)notification{

    dispatch_async(workingQueue, ^{

        [self autoSelectTabWithForceFocused:NO];
        [self showNotificationUsingFallback:YES];
    });

}

- (void)activatePlayingTab{

    dispatch_async(workingQueue, ^{

        [self autoSelectTabWithForceFocused:NO];
        [activeTab toggleTab];
    });
}

- (void)playerNext{

    [self switchPlayerWithDirection:SwithPlayerNext];
}
- (void)playerPrevious{

    [self switchPlayerWithDirection:SwithPlayerPrevious];
}

- (void)volumeUp{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self pressKey:NX_KEYTYPE_SOUND_UP];
    });
}
- (void)volumeDown{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self pressKey:NX_KEYTYPE_SOUND_DOWN];
    });
}

- (void)headphoneUnplug{

    dispatch_async(workingQueue, ^{

        [self pauseActiveTab];
    });
}



/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

- (void)sendUpdateNotificationWithString:(NSString *)message
{
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = @"Bearded Spice - Compatibility Updates";
    notification.subtitle = message;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

static NSString *const kBSUpdateOriginalTitle = @"Check for Compatibility Updates";
static NSString *const kBSUpdateCheckingTitle = @"Checking...";

- (IBAction)checkForUpdates:(id)sender
{
    // MainMenu.xib has this menu item tag set as 256
    NSMenuItem *item = [statusMenu itemWithTag:256];
    // quietly exit because this shouldn't have happened...
    if (!item)
        return;

    statusMenu.autoenablesItems = NO;
    item.enabled = NO;
    item.title = kBSUpdateCheckingTitle;


    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{
        __strong typeof(wself) sself = wself;

        BSStrategyVersionManager *manager = [BSStrategyVersionManager sharedVersionManager];
        NSUInteger updateCount = [manager performSyncUpdateCheck];

        if (updateCount == 0)
            [sself sendUpdateNotificationWithString:@"No new compatibilty updates."];

        else
        {
            NSArray *strategies = [MediaStrategyRegistry getDefaultMediaStrategyNames];
            for (NSString *name in strategies)
            {
                BSMediaStrategy *strategy = [BSMediaStrategy cacheForStrategyName:name];
                [strategy reloadData];
            }

            [sself refreshTabs:nil];

            NSString *message = [NSString stringWithFormat:@"There were %u compatibility updates.", updateCount];
            [sself sendUpdateNotificationWithString:message];
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            item.title = kBSUpdateOriginalTitle;
            item.enabled = YES;
            statusMenu.autoenablesItems = YES;
        });
    });
}

- (IBAction)openPreferences:(id)sender
{
    [self windowWillBeVisible:self.preferencesWindowController.window];
    [self.preferencesWindowController showWindow:self];

}

- (IBAction)exitApp:(id)sender {
    [NSApp terminate: nil];
}

- (void)updateActiveTabFromMenuItem:(id) sender
{

    dispatch_async(workingQueue, ^{

        [self updateActiveTab:[sender representedObject]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setStatusMenuItemsStatus];
            [activeTab activateTab];
        });
    });
}

/////////////////////////////////////////////////////////////////////
#pragma mark Windows control methods
/////////////////////////////////////////////////////////////////////

-(void)windowWillBeVisible:(id)window{

    if (window == nil)
        return;

    @synchronized(openedWindows){

        if (!openedWindows)
            openedWindows = [NSMutableSet set];

        if (!openedWindows.count) {

            [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
            //            [[NSApplication sharedApplication] setPresentationOptions:NSApplicationPresentationDefault];
        }
        [self activateApp];
        [openedWindows addObject:window];
        dispatch_async(dispatch_get_main_queue(), ^{

            [[NSApplication sharedApplication] arrangeInFront:self];
        });
    }
}

-(void)activateApp{

    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    //    [[NSRunningApplication currentApplication] activateWithOptions: (NSApplicationActivateIgnoringOtherApps | NSApplicationActivateAllWindows)];

}

-(void)removeWindow:(id)obj{

    if (obj == nil)
        return;

    @synchronized(openedWindows){

        [openedWindows removeObject:obj];

        if (![openedWindows count]){

                [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyAccessory];
//                [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyProhibited];

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

-(NSString *)trim:(NSString *)string toLength:(NSInteger)max
{
    if ([string length] > max) {
        return [NSString stringWithFormat:@"%@...", [string substringToIndex:(max - 3)]];
    }
    return [string substringToIndex: [string length]];
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

    safariApp = [self getRunningSBApplicationWithIdentifier:APPID_SAFARI];
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
    return [self updateActiveTab:[ChromeTabAdapter initWithApplication:app andWindow:chromeWindow andTab:[chromeWindow activeTab]]];
}

- (BOOL)setActiveTabShortcutForSafari:(runningSBApplication *)app {
    SafariApplication *safari = (SafariApplication *)app.sbApplication;
    // is safari.windows[0] the frontmost?
    SafariWindow *safariWindow = safari.windows[0];

    // use 'get' to force a hard reference.
    return [self updateActiveTab:[SafariTabAdapter initWithApplication:app
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
    } else if (safariApp.frontmost) {
        result = [self setActiveTabShortcutForSafari:safariApp];
    } else {

        for (runningSBApplication *app in nativeApps) {
            if (app.frontmost) {
                NativeAppTabAdapter *tab = [[nativeAppRegistry classForBundleId:app.bundleIdentifier] tabAdapterWithApplication:app];
                if (tab) {
                    result = [self updateActiveTab:tab];
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
            if ([activeTab isEqual:tab]) {

                [item setState:NSOnState];
            }
            else{

                [item setState:NSOffState];
            }
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

        NSMenuItem *item;
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
                    item = [self addSafariStatusMenuItemFor:safariTab andWindow:safariWindow];
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

- (NSArray *)refreshTabsForNativeApp:(runningSBApplication *)app
                          class:(Class)theClass {

    NSMutableArray *items = [NSMutableArray array];
    if (app) {

        TabAdapter *tab = [theClass tabAdapterWithApplication:app];

        if (tab) {

            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[self trim:tab.title toLength:40] action:@selector(updateActiveTabFromMenuItem:) keyEquivalent:@""];

            if (menuItem) {

                [items addObject:menuItem];
                [menuItem setRepresentedObject:tab];

                // check playing status
                if ([tab respondsToSelector:@selector(isPlaying)] &&
                    [(NativeAppTabAdapter *)tab isPlaying])
                    [playingTabs addObject:tab];

                [self repairActiveTabFrom:tab];
            }
        }
    }
    return items;
}

// must be invoked not on main queue
- (void)refreshTabs:(id) sender
{
    NSLog(@"Refreshing tabs...");
    @autoreleasepool {

        //hold activeTab object
        __unsafe_unretained TabAdapter *_activeTab = activeTab;
        //hold tab list
        NSArray *_menuItems = menuItems;
        NSMutableArray *newItems = [NSMutableArray array];

        [self removeAllItems];

        if (accessibilityApiEnabled) {

            BSTimeout *timeout = [BSTimeout timeoutWithInterval:COMMAND_EXEC_TIMEOUT];
            [self refreshApplications:timeout];

            [mediaStrategyRegistry beginStrategyQueries];

            [newItems addObjectsFromArray:[self refreshTabsForChrome:chromeApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForChrome:canaryApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForChrome:yandexBrowserApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForChrome:chromiumApp timeout:timeout]];
            [newItems addObjectsFromArray:[self refreshTabsForSafari:safariApp timeout:timeout]];

            for (runningSBApplication *app in nativeApps) {

                if (timeout.reached) {
                    break;
                }

                [newItems addObjectsFromArray:[self refreshTabsForNativeApp:app class:[nativeAppRegistry classForBundleId:app.bundleIdentifier]]];
            }

            [mediaStrategyRegistry endStrategyQueries];

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
        //

        dispatch_sync(dispatch_get_main_queue(), ^{

            [self resetStatusMenu];

            if (menuItems.count) {

                for (NSMenuItem *item in menuItems) {

                    [statusMenu insertItem:item atIndex:0];
                }
                //        [keyTap startWatchingMediaKeys];
            }
            else{
                //        [keyTap stopWatchingMediaKeys];
            }
        });

        //check activeTab
        if (_activeTab == activeTab) {
            activeTab = nil;
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

-(NSMenuItem *)addSafariStatusMenuItemFor:(SafariTab *)safariTab andWindow:(SafariWindow*)safariWindow
{
    TabAdapter *tab = [SafariTabAdapter initWithApplication:safariApp
                                              andWindow:safariWindow
                                                 andTab:safariTab];
    if (tab){

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

    BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:tab];
    if (strategy) {

        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[self trim:tab.title toLength:40] action:@selector(updateActiveTabFromMenuItem:) keyEquivalent:@""];
        if (menuItem){
            [menuItem setRepresentedObject:tab];

            // check playing status
            if ([strategy respondsToSelector:@selector(isPlaying:)] && [strategy isPlaying:tab])
                [playingTabs addObject:tab];

            [self repairActiveTabFrom:tab];

            return menuItem;
        }
    }

    return nil;
}

- (BOOL)updateActiveTab:(TabAdapter *)tab
{
#ifdef DEBUG
    NSLog(@"(AppDelegate - updateActiveTab) with tab %@", tab);
#endif
    // Prevent switch to tab, which not have strategy.
    BSMediaStrategy *strategy;
    if (![tab isKindOfClass:[NativeAppTabAdapter class]]) {

#ifdef DEBUG
        NSLog(@"(AppDelegate - updateActiveTab) tab %@ check strategy", tab);
#endif
        strategy = [mediaStrategyRegistry getMediaStrategyForTab:tab];
        if (!strategy) {
            return NO;
        }
    }

#ifdef DEBUG
    NSLog(@"(AppDelegate - updateActiveTab) tab %@ has strategy", tab);
#endif

    if (![tab isEqual:activeTab]) {
#ifdef DEBUG
        NSLog(@"(AppDelegate - updateActiveTab) tab %@ is different from %@", tab, activeTab);
#endif
        if (activeTab) {
            [self pauseActiveTab];
            if ([activeTab isActivated]) {
                [activeTab toggleTab];
            }
        }

        activeTab = tab;
        activeTabKey = [tab key];
        NSLog(@"Active tab set to %@", activeTab);
    }
    return YES;
}

- (void)repairActiveTabFrom:(TabAdapter *)tab{

    if ([activeTabKey isEqualToString:[tab key]]) {

        //repair activeTab
        activeTab = [tab copyStateFrom:activeTab];
    }
}

// Must be invoked in workingQueue
- (void)autoSelectTabWithForceFocused:(BOOL)forceFucused{

    [self refreshTabs:self];

    switch (playingTabs.count) {

        case 1:

            [self updateActiveTab:playingTabs[0]];
            break;

        default: // null or many

            // try to set active tab to focus
            if ((forceFucused || !activeTab)
                && [self setActiveTabShortcut]) {
                return;
            }

            if (!activeTab) {

                //try to set active tab to first item of menu
                TabAdapter *tab = [[statusMenu itemAtIndex:0] representedObject];
                if (tab)
                    [self updateActiveTab:tab];
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

- (void)showNotification {
    [self showNotificationUsingFallback:NO];
}

- (void)showNotificationUsingFallback:(BOOL)useFallback {

    dispatch_async(notificationQueue, ^{
        @autoreleasepool {

            @try {
                BSTrack *track = nil;
                if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
                    if ([activeTab respondsToSelector:@selector(trackInfo)]) {
                        track = [(NativeAppTabAdapter *)activeTab trackInfo];
                    }
                } else {

                    BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
                    if (strategy)
                        track = [strategy trackInfo:activeTab];
                }

                if (!([NSString isNullOrEmpty:track.track] &&
                      [NSString isNullOrEmpty:track.artist] &&
                      [NSString isNullOrEmpty:track.album])) {
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:[track asNotification]];
                    NSLog(@"Show Notification: %@", track);
                } else if (useFallback) {
                    [self showDefaultNotification];
                }

            }
            @catch (NSException *exception) {
                NSLog(@"(AppDelegate - showNotificationUsingFallback) Error showing notification: %@.", [exception description]);
            }
        }
    });
}

- (void)showDefaultNotification {
    NSUserNotification *notification = [[NSUserNotification alloc] init];

    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
        notification.title = [[activeTab class] displayName];
    } else {
        BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];

        notification.title = strategy.displayName;
    }

    notification.informativeText = @"No track info available";


    [[NSUserNotificationCenter defaultUserNotificationCenter]
     deliverNotification:notification];
    NSLog(@"Show Default Notification");
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
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] initWithMediaStrategyRegistry:mediaStrategyRegistry nativeAppTabRegistry:nativeAppRegistry];
        NSViewController *shortcutsViewController = [ShortcutsPreferencesViewController new];
        NSArray *controllers = @[generalViewController, shortcutsViewController];

        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[BSPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}

- (void)pauseActiveTab{

    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {

        if ([activeTab respondsToSelector:@selector(pause)])
            [(NativeAppTabAdapter *)activeTab pause];
    }
    else{

        BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        if (strategy) {
            [activeTab executeJavascript:[strategy pause]];
        }
    }

}

- (void)switchPlayerWithDirection:(SwithPlayerDirectionType)direction {

    dispatch_async(workingQueue, ^{

        @autoreleasepool {

            [self autoSelectTabWithForceFocused:NO];

            NSUInteger size = statusMenu.itemArray.count - statusMenuCount;
            if (size < 2) {
                return;
            }

            TabAdapter *tab = [[statusMenu itemAtIndex:0] representedObject];
            TabAdapter *prevTab =
            [[statusMenu itemAtIndex:(size - 1)] representedObject];
            TabAdapter *nextTab = [[statusMenu itemAtIndex:1] representedObject];
            for (int i = 0; i < size; i++) {

                if ([activeTab isEqual:tab]) {
                    if (direction == SwithPlayerNext) {
                        [self updateActiveTab:nextTab];
                    } else {
                        [self updateActiveTab:prevTab];
                    }

                    [activeTab activateTab];

                    NSUserNotification *notification = [NSUserNotification new];
                    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
                        notification.title = [[activeTab class] displayName];
                    } else {

                        BSMediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
                        if (!strategy) {
                            return;
                        }
                        notification.title = strategy.displayName;
                    }

                    notification.informativeText = [activeTab title];
                    [[NSUserNotificationCenter defaultUserNotificationCenter]
                     deliverNotification:notification];

                    return;
                }
                prevTab = tab;
                tab = nextTab;
                nextTab = i < (size - 2)
                ? [[statusMenu itemAtIndex:(i + 2)] representedObject]
                : [[statusMenu itemAtIndex:0] representedObject];
            }

            return;
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

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications methods
/////////////////////////////////////////////////////////////////////////

- (void)receivedWillCloseWindow:(NSNotification *)theNotification{
    NSWindow *window = theNotification.object;
    [self removeWindow:window];
}

- (void)receiveSleepNote:(NSNotification *)note
{
    dispatch_async(workingQueue, ^{

        [self pauseActiveTab];
    });
}

- (void) switchUserHandler:(NSNotification*) notification
{
    dispatch_async(workingQueue, ^{

        [self pauseActiveTab];
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
