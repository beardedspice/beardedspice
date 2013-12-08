//
//  AppDelegate.m
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AppDelegate.h"

#import "YoutubeHandler.h"

@implementation AppDelegate

@synthesize window;
@synthesize activeTab;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    chromeApp = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    chromeTabArray = [[NSMutableArray alloc] init];
    
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Status"];
    [statusItem setHighlightMode:YES];
    
    [statusItem setAction:@selector(refreshTabs:)];
    [statusItem setTarget:self];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self refreshTabs: menu];
}

- (void)refreshTabs:(id) sender
{
    NSLog(@"Sender was: %@", sender);
    [statusMenu removeAllItems];
    [chromeTabArray removeAllObjects];
    
    for (ChromeWindow *chromeWindow in chromeApp.windows) {
        for (ChromeTab *tab in chromeWindow.tabs) {
            NSMenuItem *tabMenuItem = [statusMenu insertItemWithTitle:[tab title] action:@selector(updateActiveTab:) keyEquivalent:@"" atIndex:0];
            [chromeTabArray insertObject:tab atIndex:[statusMenu indexOfItem:tabMenuItem]];
        }
    }
}

- (void)updateActiveTab:(id) sender
{
    NSLog(@"Sender was: %@", sender);
    [self setActiveTab:[chromeTabArray objectAtIndex:[statusMenu indexOfItem:sender]]];
    NSLog(@"Active tab now %@", [self activeTab]);
}

@end
