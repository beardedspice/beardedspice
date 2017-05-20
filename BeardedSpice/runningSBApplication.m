//
//  runningApplication.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 07.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "runningSBApplication.h"
#import "EHSystemUtils.h"

#define COMMAND_TIMEOUT         3 // 0.3 second
#define RAISING_WINDOW_DELAY    0.1 //0.1 second

@implementation runningSBApplication

- (instancetype)initWithApplication:(SBApplication *)application bundleIdentifier:(NSString *)bundleIdentifier{
    
    self = [super init];
    if (self) {
        
        _sbApplication = application;
        _bundleIdentifier = bundleIdentifier;
        _processIdentifier = 0;
        
        _sbApplication.timeout = COMMAND_TIMEOUT;
    }
    
    return self;
}

- (BOOL)frontmost{

    __block BOOL result = NO;
    [EHSystemUtils callOnMainQueue:^{
        
        NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        result = [frontmostApp.bundleIdentifier isEqualToString:self.bundleIdentifier];
    }];
    
    return result;
}

- (pid_t)processIdentifier{
    
    if (!_processIdentifier) {
        
        _processIdentifier = [[self runningAppication] processIdentifier];
    }
    
    return _processIdentifier;
}

- (void)activate{
    [EHSystemUtils callOnMainQueue:^{
        
        [[self runningAppication] activateWithOptions:(NSApplicationActivateIgnoringOtherApps | NSApplicationActivateAllWindows)];
    }];
}

- (void)hide{
    [EHSystemUtils callOnMainQueue:^{
        
        [[self runningAppication] hide];
    }];
}

- (void)makeKeyFrontmostWindow{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RAISING_WINDOW_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        AXUIElementRef ref = AXUIElementCreateApplication(self.processIdentifier);
        
        if (ref) {
            
            CFIndex count = 0;
            CFArrayRef windowArray = NULL;
            AXError err = AXUIElementGetAttributeValueCount(ref, CFSTR("AXWindows"), &count);
            if (err == kAXErrorSuccess && count) {
                
                err = AXUIElementCopyAttributeValues(ref, CFSTR("AXWindows"), 0, count, &windowArray);
                if (err == kAXErrorSuccess && windowArray) {
                    
                    for ( CFIndex i = 0; i < count; i++){
                        
                        AXUIElementRef window = CFArrayGetValueAtIndex(windowArray, i);
                        if (window) {
                            
                            CFStringRef role;
                            err = AXUIElementCopyAttributeValue(window, CFSTR("AXRole"), (CFTypeRef *)&role);
                            if (err == kAXErrorSuccess &&
                                role &&
                                CFStringCompare(role, CFSTR("AXWindow"), 0) == kCFCompareEqualTo) {
                                
                                CFRelease(role);
                                
                                err = AXUIElementCopyAttributeValue(window, CFSTR("AXSubrole"), (CFTypeRef *)&role);
                                if (err == kAXErrorSuccess &&
                                    role &&
                                    CFStringCompare(role, CFSTR("AXStandardWindow"), 0) == kCFCompareEqualTo) {
                                    
                                    CFRelease(role);
                                    AXUIElementPerformAction(window, CFSTR("AXRaise"));
                                    break;
                                }
                            }
                        }
                        
                    }
                    
                    CFRelease(windowArray);
                }
            }
            CFRelease(ref);
        }
    });
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Supporting actions in application menubar

- (NSString *)menuBarItemNameForIndexPath:(NSIndexPath *)indexPath {
    
    AXUIElementRef menuItem = [self copyMenuBarItemForIndexPath:indexPath];
    
    NSString *name;
    if (menuItem) {
        
        CFTypeRef title;
        name = (AXUIElementCopyAttributeValue(menuItem, (CFStringRef) NSAccessibilityTitleAttribute, (CFTypeRef *)&title) == kAXErrorSuccess ?
                (NSString *)CFBridgingRelease(title): nil);
        
        CFRelease(menuItem);
    }
    
    return name;
}

- (BOOL)pressMenuBarItemForIndexPath:(NSIndexPath *)indexPath {
    
    AXUIElementRef menuItem = [self copyMenuBarItemForIndexPath:indexPath];
    
    BOOL result = NO;
    if (menuItem) {
        
        result = (AXUIElementPerformAction(menuItem, (CFStringRef)NSAccessibilityPressAction) == kAXErrorSuccess);
        
        CFRelease(menuItem);
    }
    
    return result;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

- (NSRunningApplication *)runningAppication{
    NSArray *appArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:self.bundleIdentifier];
    return [appArray firstObject];
}

- (AXUIElementRef)copyMenuBarItemForIndexPath:(NSIndexPath *)indexPath{
    
    if (! indexPath.length) {
        return nil;
    }

    AXUIElementRef item = nil;
    AXUIElementRef ref = AXUIElementCreateApplication(self.processIdentifier);
    
    if (ref) {
        
        CFIndex count = 0;
        CFArrayRef items = nil;
        AXUIElementRef menu = nil;
        BOOL notFound = NO;
        if (AXUIElementCopyAttributeValue(ref, (CFStringRef)NSAccessibilityMenuBarAttribute, (CFTypeRef *)&menu) == kAXErrorSuccess
            && menu) {
            
            AXUIElementRef item = CFRetain(menu);
            for (NSUInteger i = 0; i < indexPath.length && notFound == NO; i++) {

                //getting submenu if needs it
                if (i) {
                    
                    if (AXUIElementCopyAttributeValues(item, (CFStringRef)NSAccessibilityChildrenAttribute, 0, 1, &items) == kAXErrorSuccess
                        && items) {
                        
                        CFRelease(item);
                        item = CFRetain(CFArrayGetValueAtIndex(items, 0));
                        
                        CFRelease(items);
                    }
                    else {
                        notFound = YES;
                        break;
                    }
                }
                
                NSUInteger index = [indexPath indexAtPosition:i];
                if (AXUIElementGetAttributeValueCount(item, (CFStringRef)NSAccessibilityChildrenAttribute, &count) == kAXErrorSuccess
                    && count > index ) {
                    
                    //getting menu position
                    if (AXUIElementCopyAttributeValues(item, (CFStringRef)NSAccessibilityChildrenAttribute, index, 1, &items) == kAXErrorSuccess
                        && items) {
                        
                        CFRelease(item);
                        item = CFRetain(CFArrayGetValueAtIndex(items, 0));
                        
                        CFRelease(items);
                    }
                    else {
                        
                        notFound = YES;
                    }
                }
                else {
                    
                    notFound = YES;
                }
            }

            if (notFound) {
                
                CFRelease(item);
                item = nil;
            }
            CFRelease(menu);
        }
        
        CFRelease(ref);
    }
    
    return item;
}

@end
