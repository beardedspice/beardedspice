//
//  AppDelegate.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SPMediaKeyTap.h"

#import "Chrome.h"
#import "Safari.h"
#import "Tab.h"
#import "MediaStrategyRegistry.h"

@class runningSBApplication;

@interface BeardedSpiceApp : NSApplication
@end

#import "MediaStrategy.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;

    runningSBApplication *chromeApp;
    runningSBApplication *canaryApp;
    runningSBApplication *yandexBrowserApp;

    runningSBApplication *safariApp;

    SPMediaKeyTap *keyTap;

    id <Tab> activeTab;
    MediaStrategyRegistry *mediaStrategyRegistry;

    BOOL alwaysShowNotification;

    NSWindowController *_preferencesWindowController;
}

@property (nonatomic, readonly) NSWindowController *preferencesWindowController;

- (IBAction)openPreferences:(id)sender;
- (void)showNotification;

@end
