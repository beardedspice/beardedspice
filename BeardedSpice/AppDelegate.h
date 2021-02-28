 //
//  AppDelegate.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "iTunes.h"
#import "TabAdapter.h"
#import "MediaStrategyRegistry.h"
#import "NativeAppTabsRegistry.h"
#import "BeardedSpiceHostAppProtocol.h"

#import "BSMediaStrategy.h"

#define APPDELEGATE     (AppDelegate *)([[NSApplication sharedApplication] delegate])

@class runningSBApplication;
@class BSStrategyVersionManager;
@class BSActiveTab;
@class BSStrategyWebSocketServer;

/////////////////////////////////////////////////////////////////////////
#pragma mark Defaults Keys
extern NSString *const InUpdatingStrategiesState;

/////////////////////////////////////////////////////////////////////////

extern BOOL accessibilityApiEnabled;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, NSMenuDelegate, BeardedSpiceHostAppProtocol> {
    IBOutlet NSMenu *statusMenu;
}

@property (nonatomic, readonly) dispatch_queue_t workingQueue;
@property (nonatomic, strong) BSActiveTab *activeApp;
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;
//@property (nonatomic, strong) BSStrategyVersionManager *versionManager;
@property (nonatomic) BOOL inUpdatingStrategiesState;

- (IBAction)checkForUpdates:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)clickAboutFromStatusMenu:(id)sender;

@end
