//
//  FluidTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 10.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "FluidTabAdapter.h"

#import "runningSBApplication.h"
#import "NSString+Utils.h"

#define MULTI       1


@implementation FluidTabAdapter

+(id) initWithApplication:(runningSBApplication *)application window:(FluidWindow *)window browserWindow:(FluidBrowserWindow *)browserWindow tab:(FluidTab *)tab{
    
    if ([window id] < 0) {
        return nil;
    }
    
    FluidTabAdapter *out = [[FluidTabAdapter alloc] init];
    
    // TODO(trhodeos): I can't remember why we used [object get] instead of the object directly.
    //   Checking to make sure that the object returned by 'get' is not null before using it, as it
    //   seems to be an issue w/ Fluid.
    FluidTab *gottenTab = [tab get];
    FluidWindow *gottenWindow = [window get];
    FluidBrowserWindow *gottenBrowserWindow = [browserWindow get];

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
    if (gottenBrowserWindow) {
        out.browserWindow = gottenBrowserWindow;
    }
    else{
        out.browserWindow = browserWindow;
    }
    
    [out setApplication:application];
    return out;
}

-(id) executeJavascript:(NSString *) javascript
{
    NSDate *check = [NSDate date];
    id result = [(FluidApplication *)self.application.sbApplication doJavaScript:javascript in:self.tab];
    NSLog(@"Javascript execution timeInterval: %f", ([check timeIntervalSinceNow] * -1));
    return result;
}

-(NSString *) title
{
    return [self.tab title];
}

-(NSString *) URL
{
    return [self.tab URL];
}

- (instancetype)copyStateFrom:(TabAdapter *)tab{
    
    [super copyStateFrom:tab];
    
    if ([tab isKindOfClass:[self class]]) {
        FluidTabAdapter *theTab = (FluidTabAdapter *)tab;
        
        _previousTab = theTab->_previousTab;
        _previousTopWindow = theTab->_previousTopWindow;
        _wasWindowActivated = theTab->_wasWindowActivated;
    }
    
    return self;
}

-(BOOL) isEqual:(__autoreleasing id)object
{
    if (object == nil || ![object isKindOfClass:[FluidTabAdapter class]]) return NO;
    
    return [super isEqual:object];
}

- (void)activateTab{
    
    @autoreleasepool {
        
        [super activateTab];
        
        // Грёбаная хурма
        // We must wait while application will become frontmost
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            _wasWindowActivated = NO;
            if (self.window.index != MULTI) {
                
                FluidApplication *app = (FluidApplication *)[self.application sbApplication];
                for (FluidWindow *window in app.windows) {
                    
                    NSInteger index = window.index;
                    if (index == MULTI) {
                        _previousTopWindow = [window get];
                        _wasWindowActivated = YES;
                        break;
                    }
                }
                
                self.window.index = MULTI;
            }
            
            _previousTab = [[(FluidBrowserWindow *)self.window.document selectedTab] get];
            [(FluidBrowserWindow *)self.window.document setSelectedTab:self.tab];
            
            [self.application makeKeyFrontmostWindow];
        });
    }
    
}

- (void)toggleTab{
    
    if ([(FluidApplication *)self.application.sbApplication frontmost]
        && self.window.index == MULTI
        && self.tab.index == [[(FluidBrowserWindow *)self.window.document selectedTab] index]){
        
        if (self.tab.index != _previousTab.index) {
            
            [(FluidBrowserWindow *)self.window.document setSelectedTab:_previousTab];
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

- (BOOL)frontmost{
    
    if (self.application.frontmost) {
        if ([[[(FluidBrowserWindow *)self.window.document selectedTab] get] isEqual:self.tab]) {
            
            return YES;
        }
    }
    
    return NO;
}

@end
