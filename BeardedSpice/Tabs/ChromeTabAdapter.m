//
//  ChromeTabAdapter.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ChromeTabAdapter.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"

#define MULTI       2 //Chrome feature for window indexing

@implementation ChromeTabAdapter

+(id) initWithApplication:(runningSBApplication *)application andWindow:(ChromeWindow *)window andTab:(ChromeTab *)tab
{
    ChromeTabAdapter *out = [[ChromeTabAdapter alloc] init];
    [out setTab:[tab get]];
    [out setWindow:[window get]];
    out.application = application;
    return out;
}

-(id) executeJavascript:(NSString *) javascript
{
    return [self.tab executeJavascript:javascript];
}

-(NSString *) title
{
    @autoreleasepool {
        
        NSString *title = [self.tab title];
        if ([NSString isNullOrWhiteSpace:title]){
            
            title = [self URL];
            NSInteger index = [title indexOf:@"://"];
            if (index > 0 )
                title = [title substringFromIndex:(index + 3)];
        }
        
        return title;
    }
}

-(NSString *) URL
{
    return [self.tab URL];
}

- (instancetype)copyStateFrom:(TabAdapter *)tab{
    
    [super copyStateFrom:tab];
    
    if ([tab isKindOfClass:[self class]]) {
        ChromeTabAdapter *theTab = (ChromeTabAdapter *)tab;
        
        _previousTabId = theTab->_previousTabId;
        _previousTopWindow = theTab->_previousTopWindow;
        _wasWindowActivated = theTab->_wasWindowActivated;
    }
    
    return self;
}

-(BOOL) isEqual:(__autoreleasing id)object
{
    if (object == nil || ![object isKindOfClass:[ChromeTabAdapter class]]) return NO;
    
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
                
                ChromeApplication *app = (ChromeApplication *)[self.application sbApplication];
                for (ChromeWindow *window in app.windows) {
                    
                    NSInteger index = window.index;
                    if (index == MULTI) {
                        _previousTopWindow = [window get];
                        _wasWindowActivated = YES;
                        break;
                    }
                }
                
                self.window.index = MULTI;
            }
            
            // find tab by id
            NSUInteger tabIndex = [self findTabIndexById:[self.tab id]];
            if (tabIndex != -1) {
                _previousTabId = [self.window.activeTab id];
                self.window.activeTabIndex = tabIndex;
            }
            
            [self.application makeKeyFrontmostWindow];
        });
    }
}

- (void)toggleTab{
    
    if ([(ChromeApplication *)self.application.sbApplication frontmost]
        && self.window.index == MULTI
        && [self.tab id] == [self.window.activeTab id]){
        
        if ([self.tab id] != _previousTabId) {
            
            NSInteger tabIndex = [self findTabIndexById:_previousTabId];
            if (tabIndex != -1) {
                
                _previousTabId = -1;
                self.window.activeTabIndex = tabIndex;
            }
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
        if ([[self.window activeTab] id] == self.tab.id) {
            
            return YES;
        }
    }
    
    return NO;
}

//////////////////////////////////////////////////////////////
#pragma mark Private methods
//////////////////////////////////////////////////////////////

- (NSInteger)findTabIndexById:(NSUInteger)tabId{
    
    NSUInteger count = self.window.tabs.count;
    for (NSUInteger index = 0; index < count; index++) {
        if ([(ChromeTab *)self.window.tabs[index] id] == tabId) {
            
            return (index + 1);
        }
    }

    return -1;
}

@end
