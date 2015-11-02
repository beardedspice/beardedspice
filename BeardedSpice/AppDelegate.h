 //
//  AppDelegate.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <DDHidLib/DDHidLib.h>

#import "SPMediaKeyTap.h"

#import "Chrome.h"
#import "Safari.h"
#import "iTunes.h"
#import "TabAdapter.h"
#import "MediaStrategyRegistry.h"
#import "NativeAppTabRegistry.h"
#import "BSHeadphoneUnplugListener.h"

@class runningSBApplication;

extern BOOL accessibilityApiEnabled;

#import "MediaStrategy.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, BSHeadphoneUnplugListenerProtocol> {

    IBOutlet NSMenu *statusMenu;
    NSUInteger  statusMenuCount;
    NSStatusItem *statusItem;

    runningSBApplication *chromeApp;
    runningSBApplication *canaryApp;
    runningSBApplication *yandexBrowserApp;
    runningSBApplication *chromiumApp;

    runningSBApplication *safariApp;
	runningSBApplication *webkitApp;
	
	NSMutableSet *SafariTabKeys;
	
    NSMutableArray *nativeApps;

    SPMediaKeyTap *keyTap;

    TabAdapter *activeTab;
    NSString *activeTabKey;
    
    NSMutableArray *playingTabs;
    
    MediaStrategyRegistry *mediaStrategyRegistry;
    NativeAppTabRegistry *nativeAppRegistry;

    NSWindowController *_preferencesWindowController;
    
    NSMutableSet    *openedWindows;
    
    dispatch_queue_t notificationQueue;
    
    NSArray *mikeys;
    NSArray *_appleRemotes;
    BSHeadphoneUnplugListener *_hpuListener;
}

@property (nonatomic, readonly) NSWindowController *preferencesWindowController;

- (IBAction)openPreferences:(id)sender;
- (void)showNotification;

@end
