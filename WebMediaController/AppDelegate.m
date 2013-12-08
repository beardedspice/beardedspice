//
//  AppDelegate.m
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AppDelegate.h"

#import "YoutubeHandler.h"

@implementation WebMediaControllerApp
- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}
@end

@implementation AppDelegate

@synthesize window;
@synthesize activeTab;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                             nil]];
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");
}

- (void)awakeFromNib
{
    chromeApp = [[SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"] retain];
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
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

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed) {
		NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
                // what if there is no active tab...what if!?
                [[YoutubeHandler new] pause:self.activeTab];
				break;
				
			case NX_KEYTYPE_FAST:
				debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
				break;
				
			case NX_KEYTYPE_REWIND:
				debugString = [@"Rewind pressed" stringByAppendingString:debugString];
				break;
			default:
				debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
				break;
                // More cases defined in hidsystem/ev_keymap.h
		}
        NSLog(debugString);
	}
}

@end
