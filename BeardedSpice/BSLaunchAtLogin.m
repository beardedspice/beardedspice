//
//  BSLaunchAtLogin.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 21.06.15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BSLaunchAtLogin.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - BSLaunchAtLogin
/////////////////////////////////////////////////////////////////////

@implementation BSLaunchAtLogin

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods
/////////////////////////////////////////////////////////////////////


+ (BOOL)isLaunchAtStartup {
    // See if the app is currently in LoginItems.
    LSSharedFileListItemRef itemRef = [BSLaunchAtLogin itemRefInLoginItems];
    // Store away that boolean.
    BOOL isInList = itemRef != nil;
    // Release the reference if it exists.
    if (itemRef != nil) CFRelease(itemRef);
    
    return isInList;
}

+ (void)launchAtStartup:(BOOL)shouldBeLaunchAtLogin {
    
    BOOL launchAtSatrtup = [BSLaunchAtLogin isLaunchAtStartup];
    
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return;
    
    if (shouldBeLaunchAtLogin) {
        
        if (!launchAtSatrtup){
            
            // Add the app to the LoginItems list.
            CFURLRef appUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
            LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, appUrl, NULL, NULL);
            if (itemRef) CFRelease(itemRef);
        }
    }
    else {
        
        if (launchAtSatrtup) {
            
            // Remove the app from the LoginItems list.
            LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
            LSSharedFileListItemRemove(loginItemsRef,itemRef);
            if (itemRef != nil) CFRelease(itemRef);
        }
    }
    CFRelease(loginItemsRef);
}

/////////////////////////////////////////////////////////////////////
#pragma mark Private methods
/////////////////////////////////////////////////////////////////////

+ (LSSharedFileListItemRef)itemRefInLoginItems {
    LSSharedFileListItemRef itemRef = nil;
    NSURL *itemUrl;
    CFURLRef itemURL = nil;
    
    // Get the app's URL.
    NSURL *appUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil) return nil;
    // Iterate over the LoginItems.
    NSArray *loginItems = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItemsRef, nil));
    for (int currentIndex = 0; currentIndex < [loginItems count]; currentIndex++) {
        // Get the current LoginItem and resolve its URL.
        LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItems objectAtIndex:currentIndex];
        if (LSSharedFileListItemResolve(currentItemRef, 0, &itemURL, NULL) == noErr) {
            // Compare the URLs for the current LoginItem and the app.
            itemUrl = CFBridgingRelease(itemURL);
            if ([itemUrl isEqual:appUrl]) {
                // Save the LoginItem reference.
                itemRef = currentItemRef;
            }
        }
        
        if (itemRef)
            break;
    }
    // Retain the LoginItem reference.
    if (itemRef != nil) CFRetain(itemRef);
    
    return itemRef;
}

@end
