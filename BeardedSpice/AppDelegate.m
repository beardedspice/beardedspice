  //
//  AppDelegate.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AppDelegate.h"
#include <IOKit/hid/IOHIDUsageTables.h>

#import "Shortcut.h"

#import "ChromeTabAdapter.h"
#import "SafariTabAdapter.h"
#import "NativeAppTabAdapter.h"

#import "BSPreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"
#import "ShortcutsPreferencesViewController.h"
#import "NSString+Utils.h"

#import "runningSBApplication.h"

#import "BSHidAppleRemote.h"

#define APPID_SAFARI            @"com.apple.Safari"
#define APPID_CHROME            @"com.google.Chrome"
#define APPID_CANARY            @"com.google.Chrome.canary"
#define APPID_YANDEX            @"ru.yandex.desktop.yandex-browser"

/// Because user defaults have good caching mechanism, we can use this macro.
#define ALWAYSSHOWNOTIFICATION  [[[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceAlwaysShowNotification] boolValue]

/// Delay displaying notification after changing favorited status of the current track.
#define FAVORITED_DELAY         0.3

/// Delay displaying notification after pressing next/previous track.
#define CHANGE_TRACK_DELAY      0.5

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
    // Insert code here to initialize your application
    // Register defaults for the whitelist of apps that want to use media keys
    NSMutableDictionary *registeredDefaults = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                        nil];

    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BeardedSpiceUserDefaults" ofType:@"plist"]];
    if (appDefaults)
        [registeredDefaults addEntriesFromDictionary:appDefaults];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:registeredDefaults];

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
    
    [self setupPlayControlsShortcutCallbacks];
    [self setupActiveTabShortcutCallback];
    [self setupFavoriteShortcutCallback];
    [self setupNotificationShortcutCallback];
    [self setupActivatePlayingTabShortcutCallback];
    [self setupSwitchPlayersShortcutCallback];
    
    // Application notivications
    [self setupSystemEventsCallback];

    [self refreshMikeys];
    
    // setup default media strategy
    mediaStrategyRegistry = [[MediaStrategyRegistry alloc] initWithUserDefaults:BeardedSpiceActiveControllers];
    
    // setup native apps
    nativeAppRegistry = [[NativeAppTabRegistry alloc]
        initWithUserDefaultsKey:BeardedSpiceActiveNativeAppControllers];

    nativeApps = [NSMutableArray array];
    
    // check accessibility enabled
    [self checkAccessibilityTrusted];
    
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
    [keyTap startWatchingMediaKeys];
    [self refreshKeyTapBlackList];
    
    // Init headphone unplug listener
    [self setHeadphonesListener];
    
    //Init Apple remote listener
    [self setupAppleRemotes];
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:24.0];
    [statusItem setMenu:statusMenu];
    
    [self interfaceThemeChanged:nil];
    [statusItem setHighlightMode:YES];

    // Get initial count of menu items
    statusMenuCount = statusMenu.itemArray.count;
    
    _hpuListener =
    [[BSHeadphoneUnplugListener alloc] initWithDelegate:self];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Delegate methods
/////////////////////////////////////////////////////////////////////////

- (void)menuWillOpen:(NSMenu *)menu
{
    [self autoSelectedTabs];
    [self setStatusMenuItemsStatus];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    
    return YES;
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
                [self playerToggle];
                break;
            case NX_KEYTYPE_FAST:
            case NX_KEYTYPE_NEXT:
                debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [self playerNext];
                break;
            case NX_KEYTYPE_REWIND:
            case NX_KEYTYPE_PREVIOUS:
                debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                [self playerPrevious];
                break;
            default:
                debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
                break;
                // More cases defined in hidsystem/ev_keymap.h
        }
        
        NSLog(@"%@", debugString);
    }
}

// Performs Pause method
- (void)headphoneUnplugAction{
    
    [self pauseActiveTab];
}

- (void) ddhidAppleMikey:(DDHidAppleMikey *)mikey press:(unsigned)usageId upOrDown:(BOOL)upOrDown
{
    if (upOrDown == TRUE) {
        NSLog(@"Apple Mikey keypress detected: %d", usageId);
        switch (usageId) {
            case kHIDUsage_GD_SystemMenu:
                [self playerToggle];
                break;
            case kHIDUsage_GD_SystemMenuRight:
                [self playerNext];
                break;
            case kHIDUsage_GD_SystemMenuLeft:
                [self playerPrevious];
                break;
            case kHIDUsage_GD_SystemMenuUp:
                [self pressKey:NX_KEYTYPE_SOUND_UP];
                break;
            case kHIDUsage_GD_SystemMenuDown:
                [self pressKey:NX_KEYTYPE_SOUND_DOWN];
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
                [self pressKey:NX_KEYTYPE_SOUND_UP];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonVolume_Plus");
                break;
            case kDDHidRemoteButtonVolume_Minus:
                [self pressKey:NX_KEYTYPE_SOUND_DOWN];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonVolume_Minus");
                break;
            case kDDHidRemoteButtonMenu:
                [self switchPlayerWithDirection:SwithPlayerNext];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonMenu");
                break;
            case kDDHidRemoteButtonPlay:
            case kDDHidRemoteButtonPlayPause:
                [self playerToggle];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonPlay");
                break;
            case kDDHidRemoteButtonRight:
                [self playerNext];
                NSLog(@"Apple Remote keypress detected: kDDHidRemoteButtonRight");
                break;
            case kDDHidRemoteButtonLeft:
                [self playerPrevious];
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

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

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
    [self updateActiveTab:[sender representedObject]];
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
#pragma mark Shortcuts callback setup methods
/////////////////////////////////////////////////////////////////////////

- (void)setupActiveTabShortcutCallback {
    [[MASShortcutBinder sharedBinder]
        bindShortcutWithDefaultsKey:BeardedSpiceActiveTabShortcut
                           toAction:^{

                             [self setActiveTabShortcut];
                           }];
}

- (void)setupFavoriteShortcutCallback {
    [[MASShortcutBinder sharedBinder]
        bindShortcutWithDefaultsKey:BeardedSpiceFavoriteShortcut
                           toAction:^{

                             [self autoSelectedTabs];

                             if ([activeTab isKindOfClass:
                                                [NativeAppTabAdapter class]]) {

                                 NativeAppTabAdapter *tab =
                                     (NativeAppTabAdapter *)activeTab;
                                 if ([tab respondsToSelector:@selector(
                                                                 favorite)]) {
                                     [tab favorite];
                                     if ([[tab trackInfo] favorited]) {
                                         [self showNotification];
                                     }
                                 }
                             } else {

                                 MediaStrategy *strategy =
                                     [mediaStrategyRegistry
                                         getMediaStrategyForTab:activeTab];
                                 if (strategy) {
                                     [activeTab
                                         executeJavascript:[strategy favorite]];
                                     dispatch_after(
                                         dispatch_time(
                                             DISPATCH_TIME_NOW,
                                             (int64_t)(FAVORITED_DELAY *
                                                       NSEC_PER_SEC)),
                                         dispatch_get_main_queue(), ^{

                                           if ([[strategy
                                                   trackInfo:
                                                       activeTab] favorited])
                                               [self showNotification];
                                         });
                                 }
                             }
                           }];
}

- (void)setupNotificationShortcutCallback {
    [[MASShortcutBinder sharedBinder]
        bindShortcutWithDefaultsKey:BeardedSpiceNotificationShortcut
                           toAction:^{

                             [self autoSelectedTabs];
                             [self showNotificationUsingFallback:YES];
                           }];
}

- (void)setupActivatePlayingTabShortcutCallback {
    [[MASShortcutBinder sharedBinder]
        bindShortcutWithDefaultsKey:BeardedSpiceActivatePlayingTabShortcut
                           toAction:^{

                             [self autoSelectedTabs];
                             [activeTab toggleTab];
                           }];
}

- (void)setupSwitchPlayersShortcutCallback {
    [[MASShortcutBinder sharedBinder]
        bindShortcutWithDefaultsKey:BeardedSpicePlayerPreviousShortcut
                           toAction:^{

                             [self
                                 switchPlayerWithDirection:SwithPlayerPrevious];
                           }];
    [[MASShortcutBinder sharedBinder]
        bindShortcutWithDefaultsKey:BeardedSpicePlayerNextShortcut
                           toAction:^{

                             [self switchPlayerWithDirection:SwithPlayerNext];
                           }];
}

- (void)setupPlayControlsShortcutCallbacks
{
    //Play/Pause
    [[MASShortcutBinder sharedBinder]
     bindShortcutWithDefaultsKey:BeardedSpicePlayPauseShortcut
     toAction:^{

        [self playerToggle];
    }];

    //Next
    [[MASShortcutBinder sharedBinder]
     bindShortcutWithDefaultsKey:BeardedSpiceNextTrackShortcut
     toAction:^{

        [self playerNext];
    }];

    //Previous
         [[MASShortcutBinder sharedBinder]
          bindShortcutWithDefaultsKey:BeardedSpicePreviousTrackShortcut
          toAction:^{

        [self playerPrevious];
    }];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Player Control methods
/////////////////////////////////////////////////////////////////////////

- (void)playerToggle{

    [self autoSelectedTabs];
    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {

        NativeAppTabAdapter *tab = (NativeAppTabAdapter *)activeTab;
        if ([tab respondsToSelector:@selector(toggle)]) {
            [tab toggle];
            if ([tab showNotifications] && ALWAYSSHOWNOTIFICATION &&
                ![tab frontmost])
                [self showNotification];
        }
    } else {

        MediaStrategy *strategy =
            [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        if (strategy) {
            [activeTab executeJavascript:[strategy toggle]];
            if (ALWAYSSHOWNOTIFICATION && ![activeTab frontmost]) {
                [self showNotification];
            }
        }
    }
}

- (void)playerNext {

    [self autoSelectedTabs];
    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {

        NativeAppTabAdapter *tab = (NativeAppTabAdapter *)activeTab;
        if ([tab respondsToSelector:@selector(next)]) {
            [tab next];
            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW,
                              (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{

                  if ([tab showNotifications] && ALWAYSSHOWNOTIFICATION &&
                      ![tab frontmost])
                      [self showNotification];
                });
        }
    } else {

        MediaStrategy *strategy =
            [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        if (strategy) {
            [activeTab executeJavascript:[strategy next]];
            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW,
                              (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{

                  if (ALWAYSSHOWNOTIFICATION && ![activeTab frontmost]) {
                      [self showNotification];
                  }
                });
        }
    }
}

- (void)playerPrevious {

    [self autoSelectedTabs];
    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {

        NativeAppTabAdapter *tab = (NativeAppTabAdapter *)activeTab;
        if ([tab respondsToSelector:@selector(previous)]) {
            [tab previous];
            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW,
                              (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{

                  if ([tab showNotifications] && ALWAYSSHOWNOTIFICATION &&
                      ![tab frontmost])
                      [self showNotification];
                });
        }
    } else {

        MediaStrategy *strategy =
            [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        if (strategy) {
            [activeTab executeJavascript:[strategy previous]];
            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW,
                              (int64_t)(CHANGE_TRACK_DELAY * NSEC_PER_SEC)),
                dispatch_get_main_queue(), ^{

                  if (ALWAYSSHOWNOTIFICATION && ![activeTab frontmost]) {
                      [self showNotification];
                  }
                });
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

- (void)refreshMikeys
{
    NSLog(@"Reset Mikeys");
    
    if (mikeys != nil) {
        [mikeys makeObjectsPerformSelector:@selector(stopListening) withObject:nil];
    }
    mikeys = [DDHidAppleMikey allMikeys];
    // we want to be the delegate of the mikeys
    [mikeys makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    // start listening to all mikey events
    [mikeys makeObjectsPerformSelector:@selector(setListenInExclusiveMode:) withObject:(id)kCFBooleanTrue];
    [mikeys makeObjectsPerformSelector:@selector(startListening) withObject:nil];
}


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

- (void)refreshApplications {

    chromeApp = [self getRunningSBApplicationWithIdentifier:APPID_CHROME];
    canaryApp = [self getRunningSBApplicationWithIdentifier:APPID_CANARY];
    yandexBrowserApp =
        [self getRunningSBApplicationWithIdentifier:APPID_YANDEX];

    safariApp = [self getRunningSBApplicationWithIdentifier:APPID_SAFARI];

    [nativeApps removeAllObjects];
    for (Class nativeApp in [nativeAppRegistry enabledNativeAppClasses]) {
        runningSBApplication *app =
            [self getRunningSBApplicationWithIdentifier:[nativeApp bundleId]];
        if (app) {
            [nativeApps addObject:app];
        }
    }
}

- (void)setActiveTabShortcutForChrome:(runningSBApplication *)app {
    
    ChromeApplication *chrome = (ChromeApplication *)app.sbApplication;
    // chromeApp.windows[0] is the front most window.
    ChromeWindow *chromeWindow = chrome.windows[0];
    
    // use 'get' to force a hard reference.
    [self updateActiveTab:[ChromeTabAdapter initWithApplication:app andWindow:chromeWindow andTab:[chromeWindow activeTab]]];
}

- (void)setActiveTabShortcutForSafari:(runningSBApplication *)app {
    
    SafariApplication *safari = (SafariApplication *)app.sbApplication;
    // is safari.windows[0] the frontmost?
    SafariWindow *safariWindow = safari.windows[0];
    
    // use 'get' to force a hard reference.
    [self updateActiveTab:[SafariTabAdapter initWithApplication:app
                                                      andWindow:safariWindow
                                                         andTab:[safariWindow currentTab]]];
}

- (void)setActiveTabShortcut{
    
    [self refreshApplications];
    if (chromeApp.frontmost) {
        [self setActiveTabShortcutForChrome:chromeApp];
    } else if (canaryApp.frontmost) {
        [self setActiveTabShortcutForChrome:canaryApp];
    } else if (yandexBrowserApp.frontmost) {
        [self setActiveTabShortcutForChrome:yandexBrowserApp];
    } else if (safariApp.frontmost) {
        [self setActiveTabShortcutForSafari:safariApp];
    } else {

        for (runningSBApplication *app in nativeApps) {
            if (app.frontmost) {
                NativeAppTabAdapter *tab = [[nativeAppRegistry classForBundleId:app.bundleIdentifier] tabAdapterWithApplication:app];
                if (tab) {
                    [self updateActiveTab:tab];
                }
                break;
            }
        }
    }

    [self resetMediaKeys];
}

- (void)removeAllItems
{
    NSInteger count = statusMenu.itemArray.count;
    for (int i = 0; i < (count - statusMenuCount); i++) {
        [statusMenu removeItemAtIndex:0];
    }
    
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
                return YES;
            }
        }
        
        return NO;
    }
}


- (void)refreshTabsForChrome:(runningSBApplication *)app {
    ChromeApplication *chrome = (ChromeApplication *)app.sbApplication;
    if (chrome) {
        for (ChromeWindow *chromeWindow in chrome.windows) {
            for (ChromeTab *chromeTab in chromeWindow.tabs) {
                [self addChromeStatusMenuItemFor:chromeTab andWindow:chromeWindow andApplication:app];
            }
        }
    }
}

- (void)refreshTabsForSafari:(runningSBApplication *)app {
    SafariApplication *safari = (SafariApplication *)app.sbApplication;
    if (safari) {
        for (SafariWindow *safariWindow in safari.windows) {
            for (SafariTab *safariTab in safariWindow.tabs) {
                [self addSafariStatusMenuItemFor:safariTab andWindow:safariWindow];
            }
        }
    }
}

- (void)refreshTabsForNativeApp:(runningSBApplication *)app
                          class:(Class)theClass {

    if (app) {

        TabAdapter *tab = [theClass tabAdapterWithApplication:app];

        if (tab) {

            NSMenuItem *menuItem = [statusMenu
                insertItemWithTitle:[self trim:tab.title toLength:40]
                             action:@selector(updateActiveTabFromMenuItem:)
                      keyEquivalent:@""
                            atIndex:0];

            if (menuItem) {
                [menuItem setRepresentedObject:tab];

                // check playing status
                if ([tab respondsToSelector:@selector(isPlaying)] &&
                    [(NativeAppTabAdapter *)tab isPlaying])
                    [playingTabs addObject:tab];

                [self repairActiveTabFrom:tab];
            }
        }
    }
}

- (void)refreshTabs:(id) sender
{
    NSLog(@"Refreshing tabs...");
    [self removeAllItems];
    [self refreshApplications];
    
    //hold activeTab object
    __unsafe_unretained TabAdapter *_activeTab = activeTab;

    [mediaStrategyRegistry beginStrategyQueries];
    
    [self refreshTabsForChrome:chromeApp];
    [self refreshTabsForChrome:canaryApp];
    [self refreshTabsForChrome:yandexBrowserApp];
    [self refreshTabsForSafari:safariApp];
    
    for (runningSBApplication *app in nativeApps) {
        [self refreshTabsForNativeApp:app class:[nativeAppRegistry classForBundleId:app.bundleIdentifier]];
    }
    
    [mediaStrategyRegistry endStrategyQueries];
    
    
    if ([statusMenu numberOfItems] == statusMenuCount) {
        NSMenuItem *item = [statusMenu insertItemWithTitle:@"No applicable tabs open :(" action:nil keyEquivalent:@"" atIndex:0];
        [item setEnabled:NO];
//        [keyTap stopWatchingMediaKeys];
    } else {
//        [keyTap startWatchingMediaKeys];
    }
    
    //check activeTab
    if (_activeTab == activeTab) {
        activeTab = nil;
    }
}

-(void)addChromeStatusMenuItemFor:(ChromeTab *)chromeTab andWindow:(ChromeWindow*)chromeWindow andApplication:(runningSBApplication *)application
{
    TabAdapter *tab = [ChromeTabAdapter initWithApplication:application andWindow:chromeWindow andTab:chromeTab];
    if (tab)
        [self addStatusMenuItemFor:tab];
}

-(void)addSafariStatusMenuItemFor:(SafariTab *)safariTab andWindow:(SafariWindow*)safariWindow
{
    TabAdapter *tab = [SafariTabAdapter initWithApplication:safariApp
                                              andWindow:safariWindow
                                                 andTab:safariTab];
    if (tab)
        [self addStatusMenuItemFor:tab];
}

-(BOOL)addStatusMenuItemFor:(TabAdapter *)tab {
    
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:tab];
    if (strategy) {
        
        NSMenuItem *menuItem = [statusMenu insertItemWithTitle:[self trim:tab.title toLength:40] action:@selector(updateActiveTabFromMenuItem:) keyEquivalent:@"" atIndex:0];
        if (menuItem){

            [menuItem setRepresentedObject:tab];
            
            // check playing status
            if ([strategy respondsToSelector:@selector(isPlaying:)] && [strategy isPlaying:tab])
                [playingTabs addObject:tab];
            
            [self repairActiveTabFrom:tab];
        }
        return YES;
    }
    
    return NO;
}

- (void)updateActiveTab:(TabAdapter *)tab
{
    // Prevent switch to tab, which not have strategy.
    MediaStrategy *strategy;
    if (![tab isKindOfClass:[NativeAppTabAdapter class]]) {
        
        strategy = [mediaStrategyRegistry getMediaStrategyForTab:tab];
        if (!strategy) {
            return;
        }
    }
    
    if (![tab isEqual:activeTab]) {
        [self pauseActiveTab];
    }
    
//    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
//
//        if (![tab isEqual:activeTab] &&
//            [activeTab respondsToSelector:@selector(pause)])
//            [(NativeAppTabAdapter *)activeTab pause];
//    }
//    else{
//        
//        strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
//        if (strategy && ![tab isEqual:activeTab]) {
//            [activeTab executeJavascript:[strategy pause]];
//        }
//    }
    
    activeTab = tab;
    activeTabKey = [tab key];
    NSLog(@"Active tab set to %@", activeTab);
}

- (void)repairActiveTabFrom:(TabAdapter *)tab{
    
    if ([activeTabKey isEqualToString:[tab key]]) {
        
        //repair activeTab
        activeTab = [tab copyStateFrom:activeTab];
    }
}

- (void)autoSelectedTabs{
    
    [self refreshTabs:self];
    switch (playingTabs.count) {
        case 0:
            
            // not have active tab
            if (!activeTab){
                
                // try to set active tab to focus
                [self setActiveTabShortcut];
                
                if (!activeTab) {
                    
                    //try to set active tab to first item of menu
                    TabAdapter *tab = [[statusMenu itemAtIndex:0] representedObject];
                    if (tab)
                        [self updateActiveTab:tab];
                }
                
            }
            break;
            
        case 1:

            [self updateActiveTab:playingTabs[0]];
            break;
            
        default: // many
            
            // try to set active tab to focus
            [self setActiveTabShortcut];
            
            if (!activeTab) {
                
                //try to set active tab to first item of menu
                TabAdapter *tab = [[statusMenu itemAtIndex:0] representedObject];
                if (tab)
                    [self updateActiveTab:tab];
            }
            break;
    }
    
    [self resetMediaKeys];
}

- (void)checkAccessibilityTrusted{
    
    BOOL apiEnabled = AXAPIEnabled();
    if (apiEnabled) {
        
        accessibilityApiEnabled = AXIsProcessTrusted();
    }
}

- (void)showNotification {
    [self showNotificationUsingFallback:NO];
}

- (void)showNotificationUsingFallback:(BOOL)useFallback {
    
    dispatch_async(notificationQueue, ^{
        @autoreleasepool {
            Track *track;
            if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
                if ([activeTab respondsToSelector:@selector(trackInfo)]) {
                    track = [(NativeAppTabAdapter *)activeTab trackInfo];
                }
            } else {
                
                MediaStrategy *strategy =
                [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
                if (strategy)
                    track = [strategy trackInfo:activeTab];
            }
            
            if (!([NSString isNullOrEmpty:track.track] &&
                  [NSString isNullOrEmpty:track.artist] &&
                  [NSString isNullOrEmpty:track.album])) {
                [[NSUserNotificationCenter defaultUserNotificationCenter]
                 deliverNotification:[track asNotification]];
                NSLog(@"Show Notification: %@", track);
            } else if (useFallback) {
                [self showDefaultNotification];
            }
        }
    });
}

- (void)showDefaultNotification {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
        notification.title = [[activeTab class] displayName];
    } else {
        MediaStrategy *strategy =
            [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        
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

//    [[[NSWorkspace sharedWorkspace] notificationCenter]
//     addObserver: self
//     selector: @selector(resetMediaKeys)
//     name: NSWorkspaceDidLaunchApplicationNotification
//     object: NULL];
//    
//    [[[NSWorkspace sharedWorkspace] notificationCenter]
//     addObserver: self
//     selector: @selector(resetMediaKeys)
//     name: NSWorkspaceDidTerminateApplicationNotification
//     object: NULL];
//    
//    [[[NSWorkspace sharedWorkspace] notificationCenter]
//     addObserver: self
//     selector: @selector(resetMediaKeys)
//     name: NSWorkspaceDidActivateApplicationNotification
//     object: NULL];
//
//    [[[NSWorkspace sharedWorkspace] notificationCenter]
//     addObserver: self
//     selector: @selector(refreshAllControllers:)
//     name: NSWorkspaceDidWakeNotification
//     object: NULL];

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

- (void)refreshKeyTapBlackList{

    NSMutableArray *keyTapBlackList = [NSMutableArray arrayWithCapacity:5];
    
//    if (chromeApp) {
//        [keyTapBlackList addObject:chromeApp.bundleIdentifier];
//    }
//    if (canaryApp) {
//        [keyTapBlackList addObject:canaryApp.bundleIdentifier];
//    }
//    if (yandexBrowserApp) {
//        [keyTapBlackList addObject:yandexBrowserApp.bundleIdentifier];
//    }
//    if (safariApp) {
//        [keyTapBlackList addObject:safariApp.bundleIdentifier];
//    }
    for (Class theClass in [nativeAppRegistry enabledNativeAppClasses]) {
        [keyTapBlackList addObject:[theClass bundleId]];
    }
    
    keyTap.blackListBundleIdentifiers = [keyTapBlackList copy];
    NSLog(@"Refresh Key Tab Black List.");
}

- (void)resetMediaKeys
{
    NSLog(@"Reset Media Keys.");
    [keyTap startWatchingMediaKeys];
}

- (void)pauseActiveTab{
    
    if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
        
        if ([activeTab respondsToSelector:@selector(pause)])
            [(NativeAppTabAdapter *)activeTab pause];
    }
    else{
        
        MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        if (strategy) {
            [activeTab executeJavascript:[strategy pause]];
        }
    }

}

- (BOOL)switchPlayerWithDirection:(SwithPlayerDirectionType)direction {

    @autoreleasepool {

        [self autoSelectedTabs];

        NSUInteger size = statusMenu.itemArray.count - statusMenuCount;
        if (size < 2) {
            return NO;
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

                NSUserNotification *notification = [NSUserNotification new];
                if ([activeTab isKindOfClass:[NativeAppTabAdapter class]]) {
                    notification.title = [[activeTab class] displayName];
                } else {

                    MediaStrategy *strategy = [mediaStrategyRegistry
                        getMediaStrategyForTab:activeTab];
                    if (!strategy) {
                        return NO;
                    }
                    notification.title = strategy.displayName;
                }

                notification.informativeText = [activeTab title];
                [[NSUserNotificationCenter defaultUserNotificationCenter]
                 deliverNotification:notification];

                return YES;
            }
            prevTab = tab;
            tab = nextTab;
            nextTab = i < (size - 2)
                          ? [[statusMenu itemAtIndex:(i + 2)] representedObject]
                          : [[statusMenu itemAtIndex:0] representedObject];
        }

        return NO;
    }
}

// Sets listener for detecting of headphones removing. If need it.
- (void)setHeadphonesListener {
    
    _hpuListener.enabled = [[NSUserDefaults standardUserDefaults]
                            boolForKey:BeardedSpiceRemoveHeadphonesAutopause];
}

- (void)setupAppleRemotes {

    @synchronized(BeardedSpiceUsingAppleRemote) {
        
        NSLog(@"Reset Apple Remote");
        
        if ([[NSUserDefaults standardUserDefaults]
                boolForKey:BeardedSpiceUsingAppleRemote]) {

            [_appleRemotes makeObjectsPerformSelector:@selector(stopListening)];

            _appleRemotes = [BSHidAppleRemote allRemotes];
            for (BSHidAppleRemote *item in _appleRemotes) {

                [item addMappingValue:kDDHidRemoteButtonVolume_Plus
                               forKey:@"33_31_30_21_20_2_"];
                [item addMappingValue:kDDHidRemoteButtonVolume_Minus
                               forKey:@"33_32_30_21_20_2_"];
                [item addMappingValue:kDDHidRemoteButtonRight
                               forKey:@"33_24_21_20_2_33_24_21_20_2_"];
                [item addMappingValue:kDDHidRemoteButtonLeft
                               forKey:@"33_25_21_20_2_33_25_21_20_2_"];
                [item addMappingValue:kDDHidRemoteButtonPlay
                               forKey:@"33_21_20_3_2_33_21_20_3_2_"]; // center
                                                                      // button
                [item addMappingValue:kDDHidRemoteButtonMenu
                               forKey:@"33_22_21_20_2_33_22_21_20_2_"];
                [item addMappingValue:kDDHidRemoteButtonPlayPause
                               forKey:@"33_21_20_8_2_33_21_20_8_2_"];
            }
            // we want to be the delegate of the mikeys
            [_appleRemotes makeObjectsPerformSelector:@selector(setDelegate:)
                                           withObject:self];
            // start listening to all mikey events
            [_appleRemotes
                makeObjectsPerformSelector:@selector(setListenInExclusiveMode:)
                                withObject:(id)kCFBooleanTrue];

            [_appleRemotes
                makeObjectsPerformSelector:@selector(startListening)];
        } else {

            [_appleRemotes makeObjectsPerformSelector:@selector(stopListening)];
        }
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications methods
/////////////////////////////////////////////////////////////////////////

- (void)receivedWillCloseWindow:(NSNotification *)theNotification{
    NSWindow *window = theNotification.object;
    [self removeWindow:window];
}

/**
 Method reloads: media keys, apple remote, headphones remote.
 */
- (void)refreshAllControllers:(NSNotification *)note
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self resetMediaKeys];
        [self refreshMikeys];
        [self setupAppleRemotes];
    });
}

- (void)receiveSleepNote:(NSNotification *)note
{
    [self pauseActiveTab];
}

- (void) switchUserHandler:(NSNotification*) notification
{
    [self pauseActiveTab];
}

- (void) generalPrefChanged:(NSNotification*) notification{
    
    NSString *name = notification.name;
    
    if ([name isEqualToString:GeneralPreferencesAutoPauseChangedNoticiation]) {
        
        [self setHeadphonesListener];
    }
    else if ([name isEqualToString:GeneralPreferencesUsingAppleRemoteChangedNoticiation]) {
        
        [self setupAppleRemotes];
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

@end
