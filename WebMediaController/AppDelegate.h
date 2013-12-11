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
#import "Safari.h"

@interface WebMediaControllerApp : NSApplication
@end

#import "MediaHandler.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    ChromeApplication *chromeApp;
    SafariApplication *safariApp;

    SPMediaKeyTap *keyTap;

    NSMutableArray *chromeTabArray;    
    NSMutableArray *availableHandlers;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) MediaHandler *activeHandler;

@end
