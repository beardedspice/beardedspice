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
  
    [EHSystemUtils callOnMainQueue:^{
        
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
                                
                                err = AXUIElementPerformAction(window, CFSTR("AXRaise"));
                                break;
                            }
                        }
                        
                    }
                    
                    CFRelease(windowArray);
                }
            }
            CFRelease(ref);
        }
    }];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods
/////////////////////////////////////////////////////////////////////////

- (NSRunningApplication *)runningAppication{
    NSArray *appArray = [NSRunningApplication runningApplicationsWithBundleIdentifier:self.bundleIdentifier];
    return [appArray firstObject];
}

@end
