//
//  AppDelegate.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AppDelegate.h"
#import "MASShortcut+UserDefaults.h"

#import "ChromeTabAdapter.h"
#import "SafariTabAdapter.h"

#import "MASPreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"
#import "ShortcutsPreferencesViewController.h"

#import "runningSBApplication.h"

/// Because user defaults have good caching mechanism, we can use this macro.
#define ALWAYSSHOWNOTIFICATION      [[[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceAlwaysShowNotification] boolValue]

BOOL accessibilityApiEnabled = NO;

@implementation BeardedSpiceApp
- (void)sendEvent:(NSEvent *)theEvent
{
       // If event tap is not installed, handle events that reach the app instead
       BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];

       if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
              [(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
       }
       [super sendEvent:theEvent];
}
@end

@implementation AppDelegate

/////////////////////////////////////////////////////////////////////////
#pragma mark Application Delegates
/////////////////////////////////////////////////////////////////////////

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // Register defaults for the whitelist of apps that want to use media keys
       [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                             nil]];
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
       if([SPMediaKeyTap usesGlobalMediaKeyTap]) {
              [keyTap startWatchingMediaKeys];
       } else {
              NSLog(@"Media key monitoring disabled");
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BeardedSpiceUserDefaults" ofType:@"plist"]]];

    [self setupPlayControlsShortcutCallbacks];
    [self setupActiveTabShortcutCallback];
    [self setupFavoriteShortcutCallback];
    [self setupNotificationShortcutCallback];
    [self setupActivatePlayingTabShortcutCallback];
    
    [self setupSleepCallback];

    // setup default media strategy
    mediaStrategyRegistry = [[MediaStrategyRegistry alloc] initWithUserDefaults:BeardedSpiceActiveControllers];
    
    // check accessibility enabled
    [self checkAccessibilityTrusted];
}

- (void)awakeFromNib
{
    NSImage *icon = [NSImage imageNamed:@"beard"];
    [icon setTemplate:YES]; // Support for Yosemite's dark UI

    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:icon];
    [statusItem setHighlightMode:YES];
    [statusItem setAlternateImage:[NSImage imageNamed:@"beard-highlighted"]];

    [statusItem setAction:@selector(refreshTabs:)];
    [statusItem setTarget:self];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Delegate methods
/////////////////////////////////////////////////////////////////////////

- (void)menuWillOpen:(NSMenu *)menu
{
    [self refreshTabs: menu];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    
    return YES;
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
    if (!activeTab) {
        return;
    }
    
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
                debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [self playerNext];
                break;
            case NX_KEYTYPE_REWIND:
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

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

- (IBAction)openPreferences:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:nil];
}


- (IBAction)exitApp:(id)sender {
    [NSApp terminate: nil];
}

- (void)updateActiveTabFromMenuItem:(id) sender
{
    [self updateActiveTab:[sender representedObject]];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Shortcuts callback setup methods
/////////////////////////////////////////////////////////////////////////

- (void)setupActiveTabShortcutCallback
{
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:BeardedSpiceActiveTabShortcut handler:^{
        [self refreshApplications];
        if (chromeApp.frontmost) {
            [self setActiveTabShortcutForChrome:chromeApp];
        } else if (canaryApp.frontmost) {
            [self setActiveTabShortcutForChrome:canaryApp];
        } else if (yandexBrowserApp.frontmost) {
            [self setActiveTabShortcutForChrome:yandexBrowserApp];
        } else if (safariApp.frontmost) {
            [self setActiveTabShortcutForSafari:safariApp];
        }
    }];
}

- (void)setupFavoriteShortcutCallback
{
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:BeardedSpiceFavoriteShortcut handler:^{
        MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        if (strategy) {
            [activeTab executeJavascript:[strategy favorite]];
        }
    }];
}

- (void)setupNotificationShortcutCallback
{
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:BeardedSpiceNotificationShortcut handler:^{
        [self showNotification];
    }];
}

- (void)setupActivatePlayingTabShortcutCallback
{
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:BeardedSpiceActivatePlayingTabShortcut handler:^{
        
        [activeTab activateTab];
    }];
}

- (void)setupPlayControlsShortcutCallbacks
{
    //Play/Pause
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:BeardedSpicePlayPauseShortcut handler:^{

        [self playerToggle];
    }];

    //Next
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:BeardedSpiceNextTrackShortcut handler:^{

        [self playerNext];
    }];

    //Previous
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:BeardedSpicePreviousTrackShortcut handler:^{

        [self playerPrevious];
    }];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Player Control methods
/////////////////////////////////////////////////////////////////////////

- (void)playerToggle{
    
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
    if (strategy) {
        [activeTab executeJavascript:[strategy toggle]];
        if (ALWAYSSHOWNOTIFICATION){
            [self showNotification];
        }
        
    }
}

- (void)playerNext{
    
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
    if (strategy) {
        [activeTab executeJavascript:[strategy next]];
        if (ALWAYSSHOWNOTIFICATION){
            [self showNotification];
        }
    }
    
}

- (void)playerPrevious{
    
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
    if (strategy) {
        [activeTab executeJavascript:[strategy previous]];
        if (ALWAYSSHOWNOTIFICATION){
            [self showNotification];
        }
    }

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

- (void)refreshApplications
{
    chromeApp = (runningSBApplication *)[self getRunningSBApplicationWithIdentifier:@"com.google.Chrome"];
    canaryApp = (runningSBApplication *)[self getRunningSBApplicationWithIdentifier:@"com.google.Chrome.canary"];
    
    yandexBrowserApp = (runningSBApplication *)[self getRunningSBApplicationWithIdentifier:@"ru.yandex.desktop.yandex-browser"];
    
    safariApp = (runningSBApplication *)[self getRunningSBApplicationWithIdentifier:@"com.apple.Safari"];
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

- (void)removeAllItems
{
    NSInteger count = statusMenu.itemArray.count;
    for (int i = 0; i < count - 3; i++) {
        [statusMenu removeItemAtIndex:0];
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

- (void)refreshTabs:(id) sender
{
    NSLog(@"Refreshing tabs...");
    [self removeAllItems];
    [self refreshApplications];
    
    [mediaStrategyRegistry beginStrategyQueries];
    
    [self refreshTabsForChrome:chromeApp];
    [self refreshTabsForChrome:canaryApp];
    [self refreshTabsForChrome:yandexBrowserApp];
    [self refreshTabsForSafari:safariApp];
    
    [mediaStrategyRegistry endStrategyQueries];
    
    
    if ([statusMenu numberOfItems] == 3) {
        NSMenuItem *item = [statusMenu insertItemWithTitle:@"No applicable tabs open :(" action:nil keyEquivalent:@"" atIndex:0];
        [item setEnabled:NO];
    } else if ([SPMediaKeyTap usesGlobalMediaKeyTap]) {
        [keyTap startWatchingMediaKeys];
    } else {
        NSLog(@"Media key monitoring disabled");
    }
}

-(void)addChromeStatusMenuItemFor:(ChromeTab *)chromeTab andWindow:(ChromeWindow*)chromeWindow andApplication:(runningSBApplication *)application
{
    NSMenuItem *menuItem = [self addStatusMenuItemFor:chromeTab withTitle:[chromeTab title] andURL:[chromeTab URL]];
    if (menuItem) {
        id<Tab> tab = [ChromeTabAdapter initWithApplication:application andWindow:chromeWindow andTab:chromeTab];
        [menuItem setRepresentedObject:tab];
        [self setStatusMenuItemStatus:menuItem forTab:tab];
    }
}

-(void)addSafariStatusMenuItemFor:(SafariTab *)safariTab andWindow:(SafariWindow*)safariWindow
{
    NSMenuItem *menuItem = [self addStatusMenuItemFor:safariTab withTitle:[safariTab name] andURL:[safariTab URL]];
    if (menuItem) {
        id<Tab> tab = [SafariTabAdapter initWithApplication:safariApp
                                                  andWindow:safariWindow
                                                     andTab:safariTab];
        [menuItem setRepresentedObject:tab];
        [self setStatusMenuItemStatus:menuItem forTab:tab];
    }
}

-(void)setStatusMenuItemStatus:(NSMenuItem *)item forTab:(id <Tab>)tab
{
    if (activeTab && [[activeTab key] isEqualToString:[tab key]]) {
        [item setState:NSOnState];
    }
}

-(NSMenuItem *)addStatusMenuItemFor:(id)tab withTitle:(NSString *)title andURL:(NSString *)URL
{
    if ([mediaStrategyRegistry getMediaStrategyForTab:tab]) {
        return [statusMenu insertItemWithTitle:[self trim:title toLength:40] action:@selector(updateActiveTabFromMenuItem:) keyEquivalent:@"" atIndex:0];
    }
    return NULL;
}

- (void)updateActiveTab:(id<Tab>) tab
{
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
    if (strategy && ![tab isEqual:activeTab]) {
        [activeTab executeJavascript:[strategy pause]];
    }
    
    activeTab = tab;
    NSLog(@"Active tab set to %@", activeTab);
}

- (void)checkAccessibilityTrusted{
    
    BOOL apiEnabled = AXAPIEnabled();
    if (apiEnabled) {
        
        accessibilityApiEnabled = AXIsProcessTrusted();
    }
}

- (void)showNotification
{
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
    if (strategy) {
        Track *track = [strategy trackInfo:activeTab];
        if (track) {
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:[track asNotification]];
        }
    }
}

- (void)setupSleepCallback
{
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver: self
     selector: @selector(receiveSleepNote:)
     name: NSWorkspaceWillSleepNotification object: NULL];
}

- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] initWithMediaStrategyRegistry:mediaStrategyRegistry];
        NSViewController *shortcutsViewController = [ShortcutsPreferencesViewController new];
        NSArray *controllers = @[generalViewController, shortcutsViewController];

        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications methods
/////////////////////////////////////////////////////////////////////////


- (void)receiveSleepNote:(NSNotification *)note
{
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
    if (strategy) {
        NSLog(@"Received sleep note, pausing");
        [activeTab executeJavascript:[strategy pause]];
    }
}

@end
