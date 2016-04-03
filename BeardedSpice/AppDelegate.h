 //
//  AppDelegate.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>

#import "Chrome.h"
#import "Safari.h"
#import "iTunes.h"
#import "TabAdapter.h"
#import "MediaStrategyRegistry.h"
#import "NativeAppTabRegistry.h"
#import "BeardedSpiceHostAppProtocol.h"

@class runningSBApplication;

extern BOOL accessibilityApiEnabled;

extern NSString *const SUUpdateDriverFinishedNotification;

#import "MediaStrategy.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, SUUpdaterDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate, BeardedSpiceHostAppProtocol> {

    IBOutlet NSMenu *statusMenu;
    NSUInteger  statusMenuCount;
    NSStatusItem *statusItem;
    
    // Updater
    SUUpdater *appUpdater;


    runningSBApplication *chromeApp;
    runningSBApplication *canaryApp;
    runningSBApplication *yandexBrowserApp;
    runningSBApplication *chromiumApp;

    runningSBApplication *safariApp;
    NSMutableSet *SafariTabKeys;

    NSMutableArray *nativeApps;

    TabAdapter *activeTab;
    NSString *activeTabKey;
    
    NSMutableArray *menuItems;
    NSMutableArray *playingTabs;
    
    MediaStrategyRegistry *mediaStrategyRegistry;
    NativeAppTabRegistry *nativeAppRegistry;

    NSWindowController *_preferencesWindowController;
    
    NSMutableSet    *openedWindows;
    
    dispatch_queue_t workingQueue;
    dispatch_queue_t notificationQueue;
    
    NSXPCConnection *_connectionToService;
    
    BOOL _AXAPIEnabled;
}

@property (nonatomic, readonly) NSWindowController *preferencesWindowController;

- (IBAction)openPreferences:(id)sender;
- (IBAction)checkForUpdates:(id)sender;

- (void)showNotification;

@end
