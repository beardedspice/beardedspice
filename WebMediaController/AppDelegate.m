//
//  AppDelegate.m
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AppDelegate.h"


#import "Chrome.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    ChromeApplication * chromeApp = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Status"];
    [statusItem setHighlightMode:YES];
    
    for (ChromeWindow *window in chromeApp.windows) {
        for (ChromeTab *tab in window.tabs) {
            
            NSLog([tab URL]);
        }
    }
}


@end
