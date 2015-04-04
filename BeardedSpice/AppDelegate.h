//
//  AppDelegate.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>

#import "SPMediaKeyTap.h"

#import "Chrome.h"
#import "Safari.h"
#import "iTunes.h"
#import "Tab.h"
#import "MediaStrategyRegistry.h"

@class runningSBApplication;

extern BOOL accessibilityApiEnabled;

extern NSString *const SUUpdateDriverFinishedNotification;

@interface BeardedSpiceApp : NSApplication
@end

#import "MediaStrategy.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, SUUpdaterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSUInteger  statusMenuCount;
    NSStatusItem *statusItem;
    
    // Updater
    SUUpdater *appUpdater;


    runningSBApplication *chromeApp;
    runningSBApplication *canaryApp;
    runningSBApplication *yandexBrowserApp;

    runningSBApplication *safariApp;
    
    runningSBApplication *iTunesApp;
    BOOL iTunesNeedDisplayNotification;

    SPMediaKeyTap *keyTap;

    id <Tab> activeTab;
    MediaStrategyRegistry *mediaStrategyRegistry;

    NSWindowController *_preferencesWindowController;
    
    NSMutableSet    *openedWindows;
}

@property (nonatomic, readonly) NSWindowController *preferencesWindowController;

- (IBAction)openPreferences:(id)sender;
- (IBAction)checkForUpdates:(id)sender;

- (void)showNotification;

@end
