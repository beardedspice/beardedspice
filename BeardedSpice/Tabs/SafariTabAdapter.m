//
//  SafariTabAdapter.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SafariTabAdapter.h"

#import "runningSBApplication.h"
#import "NSString+Utils.h"

#define MULTI       1
#define WAIT_FRONTMOST_DELAY    0.2

@implementation SafariTabAdapter

+ (id)initWithApplication:(runningSBApplication *)application andWindow:(SafariWindow *)window andTab:(SafariTab *)tab
{
    SafariTabAdapter *out = [SafariTabAdapter new];

    // TODO(trhodeos): I can't remember why we used [object get] instead of the object directly.
    //   Checking to make sure that the object returned by 'get' is not null before using it, as it
    //   seems to be an issue w/ safari.
    SafariTab *gottenTab = [tab get];
    SafariWindow *gottenWindow = [window get];
    if (gottenTab != nil) {
        [out setTab:gottenTab];
    } else {
        [out setTab:tab];
    }
    if (gottenWindow != nil) {
        [out setWindow:gottenWindow];
    } else {
        [out setWindow:window];
    }
    [out setApplication:application];
    return out;
}

-(id) executeJavascript:(NSString *) javascript
{
    return [(SafariApplication *)self.application.sbApplication doJavaScript:javascript in:self.tab];
}

-(NSString *) title
{
    return [self.tab name];
}

-(NSString *) URL
{
    return [self.tab URL];
}

- (instancetype)copyStateFrom:(TabAdapter *)tab{
    
    [super copyStateFrom:tab];
    
    if ([tab isKindOfClass:[self class]]) {
        SafariTabAdapter *theTab = (SafariTabAdapter *)tab;
        
        _previousTab = theTab->_previousTab;
        _previousTopWindow = theTab->_previousTopWindow;
        _wasWindowActivated = theTab->_wasWindowActivated;
    }
    
    return self;
}

-(BOOL) isEqual:(__autoreleasing id)object
{
    if (object == nil || ![object isKindOfClass:[SafariTabAdapter class]]) return NO;

    return [super isEqual:object];
}

- (void)activateTab{
    
    @autoreleasepool {
        
        [super activateTab];
        
        // Грёбаная хурма
        // We must wait while application will become frontmost
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WAIT_FRONTMOST_DELAY * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            _wasWindowActivated = NO;
            if (self.window.index != MULTI) {
                
                SafariApplication *app = (SafariApplication *)[self.application sbApplication];
                for (SafariWindow *window in [[app windows] get]) {
                    
                    NSInteger index = window.index;
                    if (index == MULTI) {
                        _previousTopWindow = [window get];
                        _wasWindowActivated = YES;
                        break;
                    }
                }
                
                self.window.index = MULTI;
            }
            
            _previousTab = [self.window.currentTab get];
            self.window.currentTab = self.tab;
            
            [self.application makeKeyFrontmostWindow];
        });
    }
    
}

- (void)toggleTab{
    
    if ([(SafariApplication *)self.application.sbApplication frontmost]
        && self.window.index == MULTI
        && self.tab.index == self.window.currentTab.index){
        
        if (self.tab.index != _previousTab.index) {
            
            self.window.currentTab = _previousTab;
            _previousTab = nil;
        }

        if (_wasWindowActivated) {
            
            _previousTopWindow.index = MULTI;
            _wasWindowActivated = NO;
            [self.application makeKeyFrontmostWindow];
            
            _previousTopWindow = nil;
        }

        if (_wasActivated) {
            
            [self.application hide];
            _wasActivated = NO;
        }
    }
    else
        [self activateTab];
}

- (BOOL)frontmost {
    if (self.application.frontmost && self.window.index == MULTI &&
        self.tab.index == self.window.currentTab.index) {

        return YES;
    }

    return NO;
}

@end
