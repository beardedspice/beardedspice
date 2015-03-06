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

    [self setupActiveTabShortcutCallback];
    [self setupFavoriteShortcutCallback];
    [self setupNotificationShortcutCallback];
    
    [self setupActivatePlayingTabShortcutCallback];
    
    [self setupSleepCallback];

    // set whether to always show notifications
    alwaysShowNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceAlwaysShowNotification] boolValue];

    // setup default media strategy
    mediaStrategyRegistry = [[MediaStrategyRegistry alloc] initWithUserDefaults:BeardedSpiceActiveControllers];
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

- (void)menuWillOpen:(NSMenu *)menu
{
    [self refreshTabs: menu];
}

- (void)removeAllItems
{
    NSInteger count = statusMenu.itemArray.count;
    for (int i = 0; i < count - 3; i++) {
        [statusMenu removeItemAtIndex:0];
    }
}

- (IBAction)exitApp:(id)sender {
    [NSApp terminate: nil];
}

- (void)refreshTabsForChrome:(ChromeApplication *) chrome {
    if (chrome) {
        for (ChromeWindow *chromeWindow in chrome.windows) {
            for (ChromeTab *chromeTab in chromeWindow.tabs) {
                [self addChromeStatusMenuItemFor:chromeTab andWindow:chromeWindow andApplication:chrome];
            }
        }
    }
}

- (void)refreshTabsForSafari:(SafariApplication *) safari {
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

-(void)addChromeStatusMenuItemFor:(ChromeTab *)chromeTab andWindow:(ChromeWindow*)chromeWindow andApplication:(ChromeApplication *)application
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

- (void)updateActiveTabFromMenuItem:(id) sender
{
    [self updateActiveTab:[sender representedObject]];
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
        MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
        if (!strategy) {
            return;
        }
              NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
        switch (keyCode) {
                     case NX_KEYTYPE_PLAY:
                            debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
                [activeTab executeJavascript:[strategy toggle]];
                break;
                     case NX_KEYTYPE_FAST:
                            debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [activeTab executeJavascript:[strategy next]];
                            break;
                     case NX_KEYTYPE_REWIND:
                            debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                [activeTab executeJavascript:[strategy previous]];
                            break;
                     default:
                            debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
                            break;
                // More cases defined in hidsystem/ev_keymap.h
              }

        if (alwaysShowNotification == YES)
        {
            [self showNotification];
        }

        NSLog(@"%@", debugString);
       }
}

-(SBApplication *)getRunningSBApplicationWithIdentifier:(NSString *)bundleIdentifier
{
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    if ([apps count] > 0) {
        NSRunningApplication *app = [apps objectAtIndex:0];
        NSLog(@"App %@ is running %@", bundleIdentifier, app);
        return [SBApplication applicationWithProcessIdentifier:[app processIdentifier]];
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
    chromeApp = (ChromeApplication *)[self getRunningSBApplicationWithIdentifier:@"com.google.Chrome"];
    canaryApp = (ChromeApplication *)[self getRunningSBApplicationWithIdentifier:@"com.google.Chrome.canary"];
    yandexBrowserApp = (ChromeApplication *)[self getRunningSBApplicationWithIdentifier:@"ru.yandex.desktop.yandex-browser"];
    safariApp = (SafariApplication *)[self getRunningSBApplicationWithIdentifier:@"com.apple.Safari"];
}

- (void)setActiveTabShortcutForChrome:(ChromeApplication *)chrome {
    // chromeApp.windows[0] is the front most window.
    ChromeWindow *chromeWindow = chrome.windows[0];

    // use 'get' to force a hard reference.
    [self updateActiveTab:[ChromeTabAdapter initWithApplication:chrome andWindow:chromeWindow andTab:[chromeWindow activeTab]]];
}

- (void)setActiveTabShortcutForSafari:(SafariApplication *)safari {
    // is safari.windows[0] the frontmost?
    SafariWindow *safariWindow = safari.windows[0];

    // use 'get' to force a hard reference.
    [self updateActiveTab:[SafariTabAdapter initWithApplication:safari
                                                      andWindow:safariWindow
                                                         andTab:[safariWindow currentTab]]];
}

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

- (void)receiveSleepNote:(NSNotification *)note
{
    MediaStrategy *strategy = [mediaStrategyRegistry getMediaStrategyForTab:activeTab];
    if (strategy) {
        NSLog(@"Received sleep note, pausing");
        [activeTab executeJavascript:[strategy pause]];
    }
}

- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        NSViewController *generalViewController = [[GeneralPreferencesViewController alloc] initWithMediaStrategyRegistry:mediaStrategyRegistry];
        NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, nil];

        NSString *title = NSLocalizedString(@"Preferences", @"Common title for Preferences window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];

        // this is not my favorite. I'd welcome a better way to update alwaysShowNotification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAlwaysShowNotification:) name:@"BeardedSpiceUpdatePreferences" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesClosed:) name:NSWindowWillCloseNotification object:nil];
        NSLog(@"THis!");
    }
    return _preferencesWindowController;
}

-(void)preferencesClosed:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateAlwaysShowNotification:(NSNotification *)notification
{
    // update whether to always show notifications
    alwaysShowNotification = [[[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceAlwaysShowNotification] boolValue];
}


- (IBAction)openPreferences:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:nil];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{

    return YES;
}

@end
