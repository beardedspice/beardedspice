//
//  AFSAppleScriptSupport.m
//  BeardedSpice
//
//  Created by Quentin Carnicelli on 9/7/16.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//


#import "AppDelegate.h"
#import "BSActiveTab.h"

@interface BSAppleScriptPlayPauseCommand: NSScriptCommand { } @end
@interface BSAppleScriptNextCommand: NSScriptCommand { } @end
@interface BSAppleScriptPrevCommand: NSScriptCommand { } @end

@implementation AppDelegate (AppleScriptAdditions)

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key
{
	return [[NSSet setWithObjects: @"fullTitle", nil] containsObject:key];
}

- (NSString*)fullTitle
{
    //Ok this is cheap, but we wanna force an update. This doesn't -quite- work either,
    //because the update is async, and we won't get the results back in time.
    //But at least they'll update -eventually-, so your next call will get something useful

    [self menuNeedsUpdate: statusMenu];

    //Safe to access activeTab ivar here?
    return [self.activeApp title];
}

@end

@implementation BSAppleScriptPlayPauseCommand

- (id)performDefaultImplementation
{
    AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    [delegate playPauseToggle];
    return nil;
}

@end

@implementation BSAppleScriptNextCommand

- (id)performDefaultImplementation
{
    AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    [delegate nextTrack];
	return nil;
}

@end

@implementation BSAppleScriptPrevCommand

- (id)performDefaultImplementation
{
    AppDelegate* delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    [delegate previousTrack];
    return nil;
}

@end