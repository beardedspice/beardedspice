 //
//  AppDelegate.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Chrome.h"
#import "Safari.h"
#import "iTunes.h"
#import "TabAdapter.h"
#import "MediaStrategyRegistry.h"
#import "NativeAppTabRegistry.h"
#import "BeardedSpiceHostAppProtocol.h"

#import "BSMediaStrategy.h"

#define APPDELEGATE     (AppDelegate *)([[NSApplication sharedApplication] delegate])

@class runningSBApplication;
@class BSStrategyVersionManager;
@class BSActiveTab;
@class BSStrategyWebSocketServer;

extern BOOL accessibilityApiEnabled;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate, BeardedSpiceHostAppProtocol> {

    IBOutlet NSMenu *statusMenu;
    NSUInteger  statusMenuCount;
    NSStatusItem *statusItem;

    runningSBApplication *chromeApp;
    runningSBApplication *canaryApp;
    runningSBApplication *yandexBrowserApp;
    runningSBApplication *chromiumApp;
    runningSBApplication *vivaldiApp;

    runningSBApplication *safariApp;
    runningSBApplication *safariTPApp;
    NSMutableSet *SafariTabKeys;

    NSMutableArray *nativeApps;

    NSMutableArray *menuItems;
    NSMutableArray *playingTabs;

    NativeAppTabRegistry *nativeAppRegistry;

    NSWindowController *_preferencesWindowController;

    NSMutableSet    *openedWindows;

    dispatch_queue_t workingQueue;

    NSXPCConnection *_connectionToService;
    
    BSStrategyWebSocketServer *_webSocketServer;

    BOOL _AXAPIEnabled;
}

@property (nonatomic, strong) BSActiveTab *activeApp;
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;
@property (nonatomic, strong) BSStrategyVersionManager *versionManager;

- (IBAction)checkForUpdates:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (void)showNotification;

- (IBAction)clickTest:(id)sender;


/////////////////////////////////////////////////////////////////////
#pragma mark Windows control methods

-(void)windowWillBeVisible:(id)window;
-(void)removeWindow:(id)obj;

@end
