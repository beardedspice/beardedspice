//
//  AppDelegate.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "AppDelegate.h"

#import "YoutubeHandler.h"
#import "PandoraHandler.h"
#import "BandCampHandler.h"
#import "GroovesharkHandler.h"
#import "HypeMachineHandler.h"
#import "ChromeTabAdapter.h"
#import "SafariTabAdapter.h"
#import "SoundCloudHandler.h"

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

    availableHandlers = [[NSMutableArray alloc] init];
    // TODO: add more handler classes here
    [availableHandlers addObject:[YoutubeHandler class]];
    [availableHandlers addObject:[PandoraHandler class]];
    [availableHandlers addObject:[BandCampHandler class]];
    [availableHandlers addObject:[GroovesharkHandler class]];
    [availableHandlers addObject:[HypeMachineHandler class]];
    [availableHandlers addObject:[SoundCloudHandler class]];
}

- (void)awakeFromNib
{
    chromeApp = [SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"];
    safariApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
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

- (void)refreshTabs:(id) sender
{
    NSLog(@"Sender was: %@", sender);
    // TODO: figure out memory issues
    [statusMenu removeAllItems];
    [chromeTabArray removeAllObjects];
    
    for (ChromeWindow *chromeWindow in chromeApp.windows) {
        for (ChromeTab *chromeTab in chromeWindow.tabs) {
            // JF: ChromeTab implicitly implements our protocol. we could just cast it (id<Tab>)
            [self addHandlersForTab:[ChromeTabAdapter initWithTab:chromeTab]];
        }
    }
    
    for (SafariWindow *safariWindow in safariApp.windows) {
        for (SafariTab *safariTab in safariWindow.tabs) {
            [self addHandlersForTab:[SafariTabAdapter initWithApplication:safariApp andTab:safariTab]];
        }
    }
}

-(void)addHandlersForTab:(id <Tab>)tab
{
    for (Class handler in availableHandlers) {
        if ([self isValidHandler:handler forUrl:[tab URL]]) {
            NSLog(@"%@ is valid for url %@", handler, [tab URL]);
            NSMenuItem *tabMenuItem = [statusMenu insertItemWithTitle:[tab title] action:@selector(updateActiveHandler:) keyEquivalent:@"" atIndex:0];
            // TODO: how do I memory management in obj-c?
            // taking this out makes everything blow up.
            // .... halp
            
            if ([self.activeHandler.tab isEqual:tab]) {
                [tabMenuItem setState:NSOnState];
            }
            
            MediaHandler *mediaHandler = [[handler alloc] init];
            [mediaHandler setTab:tab];
            [chromeTabArray insertObject:mediaHandler atIndex:[statusMenu indexOfItem:tabMenuItem]];
            break;
        }
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

@end
