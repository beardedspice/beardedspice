//
//  AppDelegate.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AppDelegate.h"
#import "MASShortcut+Monitoring.h"

#import "Tab.h"
#import "ChromeTabAdapter.h"
#import "SafariTabAdapter.h"


@implementation BeardedSpiceApp
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
@synthesize activeHandler;

NSString *const preferenceGlobalShortcut = @"ActivateCurrentTab";

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // Register defaults for the whitelist of apps that want to use media keys
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
                                                             nil]];
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap]) {
		[keyTap startWatchingMediaKeys];
	} else {
		NSLog(@"Media key monitoring disabled");
    }

    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_F8 modifierFlags:NSCommandKeyMask];
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
        id tab = nil;
        if (chromeApp.frontmost) {
            // chromeApp.windows[0] is the front most window.
            tab = [ChromeTabAdapter initWithTab:[chromeApp.windows[0] activeTab]];
        } else if (safariApp.frontmost) {
            // is safari.windows[0] the frontmost?
            tab = [SafariTabAdapter initWithApplication:safariApp andWindow: safariApp.windows[0] andTab:[safariApp.windows[0] currentTab]];
        }
        if (tab) {
            NSLog(@"Global shortcut encountered. Determining handler for %@", tab);
            id handler = [mediaHandlerRegistry getMediaHandlerForTab:tab];
            if (handler) {
                NSLog(@"Using %@ as handler for %@.", handler, tab);
                [self setActiveHandler: handler];
            } else {
                NSLog(@"No valid handler found for %@", tab);
            }
        }
    }];
    
    mediaHandlerRegistry = [MediaHandlerRegistry getDefaultRegistry];
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    chromeTabArray = [[NSMutableArray alloc] init];

    [statusItem setMenu:statusMenu];
    [statusItem setImage:[NSImage imageNamed:@"youtube-play.png"]];
    [statusItem setHighlightMode:YES];

    [statusItem setAction:@selector(refreshTabs:)];
    [statusItem setTarget:self];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self refreshTabs: menu];
}

/**
 A bit of hackery to allow us to dynamically determine if the url is valid for the given handler
*/
- (BOOL) isValidHandler:(Class) handler forUrl:(NSString *)url
{
    if (![handler isSubclassOfClass:[MediaHandler class]]) {
        return NO;
    }

    BOOL output;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[handler methodSignatureForSelector:@selector(isValidFor:)]];
    [inv setTarget:handler];
    [inv setSelector:@selector(isValidFor:)];
    [inv setArgument:&url atIndex:2]; // 0 is target, 1 is selector
    [inv invoke];
    [inv getReturnValue:&output];
    return output;
}
- (void)removeAllItems
{
    NSInteger count = statusMenu.itemArray.count;
    for (int i = 0; i < count - 2; i++) {
        [statusMenu removeItemAtIndex:0];
    }
    [chromeTabArray removeAllObjects];
}

- (IBAction)exitApp:(id)sender {
    [NSApp terminate: nil];
}

- (void)refreshTabs:(id) sender
{
    NSLog(@"Sender was: %@", sender);
    // TODO: figure out memory issues
    [self removeAllItems];

    chromeApp = (ChromeApplication *)[self getRunningSBApplicationWithIdentifier:@"com.google.Chrome"];
    safariApp = (SafariApplication *)[self getRunningSBApplicationWithIdentifier:@"com.apple.Safari"];

    if (chromeApp != NULL) {
        for (ChromeWindow *chromeWindow in chromeApp.windows) {
            for (ChromeTab *chromeTab in chromeWindow.tabs) {
                // JF: ChromeTab implicitly implements our protocol. we could just cast it (id<Tab>)
                [self addHandlersForTab:[ChromeTabAdapter initWithTab:chromeTab]];
            }
        }
    }
    if (safariApp != NULL) {
        for (SafariWindow *safariWindow in safariApp.windows) {
            for (SafariTab *safariTab in safariWindow.tabs) {
                [self addHandlersForTab:[SafariTabAdapter initWithApplication:safariApp andWindow:safariWindow andTab:safariTab]];
            }
        }
    }
    
    if (chromeTabArray.count == 0) {
        NSMenuItem *item = [statusMenu insertItemWithTitle:@"No applicable tabs open :(" action:nil keyEquivalent:@"" atIndex:0];
        [item setEnabled:NO];
    }
}

-(void)addHandlersForTab:(id <Tab>)tab
{
    MediaHandler *handler = [mediaHandlerRegistry getMediaHandlerForTab:tab];
    if (handler) {
        NSMenuItem *tabMenuItem = [statusMenu insertItemWithTitle:[tab title] action:@selector(updateActiveHandler:) keyEquivalent:@"" atIndex:0];

        if ([self.activeHandler.tab isEqual:tab]) {
            [tabMenuItem setState:NSOnState];
        }
        
        [chromeTabArray insertObject:handler atIndex:[statusMenu indexOfItem:tabMenuItem]];
    }
}

- (void)updateActiveHandler:(id) sender
{
    NSLog(@"Sender was: %@", sender);
    [self setActiveHandler:[chromeTabArray objectAtIndex:[statusMenu indexOfItem:sender]]];
    NSLog(@"Active handler now %@", [self activeHandler]);
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
                [self.activeHandler toggle];
				break;
			case NX_KEYTYPE_FAST:
				debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [self.activeHandler next];
				break;

			case NX_KEYTYPE_REWIND:
				debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                [self.activeHandler previous];
				break;
			default:
				debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
				break;
                // More cases defined in hidsystem/ev_keymap.h
		}
        NSLog(@"%@", debugString);
	}
}

-(SBApplication *)getRunningSBApplicationWithIdentifier:(NSString *)bundleIdentifier
{
    NSArray *apps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleIdentifier];
    if ([apps count] > 0) {
        NSRunningApplication *app = [apps objectAtIndex:0];
        NSLog(@"App %@ is running %@", bundleIdentifier, app);
        return [SBApplication applicationWithProcessIdentifier:[app processIdentifier]];
    }
    return NULL;
}

@end
