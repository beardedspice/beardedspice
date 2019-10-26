//
//  BSWebTabSafariAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 13/10/2019.
//  Copyright © 2019 BeardedSpice. All rights reserved.
//

#import "BSWebTabSafariAdapter.h"
#import "runningSBApplication.h"

@implementation BSWebTabSafariAdapter

static NSSet *_safariBundleIds;

/////////////////////////////////////////////////////////////////////////
#pragma mark Public methods

- (BOOL)suitableForSocket {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _safariBundleIds = [NSSet setWithArray:@[BS_DEFAULT_SAFARI_BUBDLE_ID, BS_SAFARI_TECHPREVIEW_ID]];
    });
    @autoreleasepool {
        runningSBApplication *app = self.application;
        
        if (app.bundleIdentifier && [_safariBundleIds containsObject:app.bundleIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)activateTab {

    NSDictionary *response = [self sendMessage:@"activate"];
    
    return [response[@"result"] boolValue]
    && [self windowMakefrontmostIfNeedFromResponse:response];
}

- (BOOL)deactivateTab {
    
    if ([self frontmost]) {
        if ([self isActivated]) {
            NSDictionary *response = [self sendMessage:@"hide"];
            return [response[@"result"] boolValue]
            && [self windowMakefrontmostIfNeedFromResponse:response];
        }
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<BSWebTabSafariAdapter:%p> bundleId: %@, title: %@", self, self.application.bundleIdentifier, self.title];
}


#pragma mark Private methods

- (BOOL)windowMakefrontmostIfNeedFromResponse:(__unsafe_unretained NSDictionary *)response {
    if (response && [response isKindOfClass:[NSDictionary class]]) {
        NSString *windowId = response[@"windowIdForMakeFrontmost"];
        
        if (windowId) {
            AXUIElementRef window = [self AXWindowByIdentifier:windowId];
            if (window) {
                BS_LOG(LOG_DEBUG, @"Window obtained: %p", window);
                AXUIElementPerformAction(window, CFSTR("AXRaise"));
                CFRelease(window);
                return YES;
            }
            return NO;
        }
    }
    return YES;
}

- (AXUIElementRef)AXWindowByIdentifier:(__unsafe_unretained NSString *)windowId{
    
    AXUIElementRef ref = AXUIElementCreateApplication(self.application.processIdentifier);
    AXUIElementRef result = NULL;
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
                        if (err == kAXErrorSuccess && role){

                            if (CFStringCompare(role, CFSTR("AXWindow"), 0) == kCFCompareEqualTo) {

                                CFStringRef subrole;
                                err = AXUIElementCopyAttributeValue(window, CFSTR("AXSubrole"), (CFTypeRef *)&subrole);
                                if (err == kAXErrorSuccess && subrole) {
                                    
                                    CFStringRef identifier;
                                    err = AXUIElementCopyAttributeValue(window, CFSTR("AXIdentifier"), (CFTypeRef *)&identifier);
                                    if (err == kAXErrorSuccess && identifier) {
                                        
                                        if (CFStringCompare(identifier, (__bridge CFStringRef)windowId, 0) == kCFCompareEqualTo) {
                                            result = window;
                                            CFRetain(result);
                                            
                                            CFRelease(identifier);
                                            CFRelease(subrole);
                                            CFRelease(role);
                                            break;
                                        }
                                        
                                        CFRelease(identifier);
                                    }
                                    
                                    CFRelease(subrole);
                                }
                            }
                            
                            CFRelease(role);
                        }
                    }
                    
                }
                
                CFRelease(windowArray);
            }
        }
        CFRelease(ref);
    }
    return result;
}



@end
