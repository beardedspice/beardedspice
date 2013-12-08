//
//  AppDelegate.h
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPMediaKeyTap.h"
#import "Chrome.h"

@interface WebMediaControllerApp : NSApplication
@end

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    ChromeApplication *chromeApp;
    SPMediaKeyTap *keyTap;
    NSMutableArray *chromeTabArray;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) ChromeTab *activeTab;

@end
