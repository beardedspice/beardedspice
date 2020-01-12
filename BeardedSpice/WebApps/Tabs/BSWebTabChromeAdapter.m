//
//  BSWebTabChromeAdapter.m
//  Beardie
//
//  Created by Roman Sokolov on 12.01.2020.
//  Copyright © 2020 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSWebTabChromeAdapter.h"
#import "AppDelegate.h"
#import "runningSBApplication.h"

#define STANDALONE_ACTIVATE_TAB_TIMEOUT         0.2 //seconds

@interface BSWebTabAdapter()
- (runningSBApplication *)obtainApplication;
@end

@implementation BSWebTabChromeAdapter{
    NSString *_realBundleId;
    runningSBApplication *_application;
}

static NSSet *_chromeBundleIds;

/////////////////////////////////////////////////////////////////////////
#pragma mark Public methods

- (BOOL)suitableForSocket {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chromeBundleIds = [NSSet setWithArray:@[BS_DEFAULT_CHROME_BUNDLE_ID]];
    });
    @autoreleasepool {
        runningSBApplication *app = self.application;
        
        if (app.bundleIdentifier && [_chromeBundleIds containsObject:app.bundleIdentifier]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark TabAdapter override

- (runningSBApplication *)application {
    if (_application == nil) {
        @synchronized (self) {
            if (_application == nil) {
                if (_realBundleId.length) {
                    _application = [runningSBApplication sharedApplicationForBundleIdentifier:_realBundleId];
                    BSLog(BSLOG_INFO, @"New application object from bundleid \"%@\" creating result: %@", _realBundleId, _application ? @"YES" : @"NO");
                }
                else {
                    _application = [self obtainApplication];
                }
            }
        }
    }
    return _application;
}

- (BOOL)activateTab {

    if (self.standalone) {
        if (_realBundleId.length) {
            BSLog(BSLOG_DEBUG, @"Standalone activate tab.");
            return YES;
        }
        else {
            
            BSLog(BSLOG_DEBUG, @"Standalone initial activate tab.");
            // delaying activation tab
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(STANDALONE_ACTIVATE_TAB_TIMEOUT * NSEC_PER_SEC)),
                               [(AppDelegate *)(NSApp.delegate) workingQueue], ^{
                    [self sendMessage:@"activate"];
                    [[NSWorkspace sharedWorkspace] addObserver:self
                                                    forKeyPath:@"frontmostApplication"
                                                       options:NSKeyValueObservingOptionNew
                                                       context:&self->_realBundleId];
                });
            });
        }
    }
    else {
        BSLog(BSLOG_DEBUG, @"Ordinary activate tab.");
        [self sendMessage:@"activate"];
    }
    return YES;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context{
    
    // FOR OBTAINING real bundle id of the Desktop PWA
    if ([keyPath isEqualToString:@"frontmostApplication"] && context == &_realBundleId) {
        if ([change[NSKeyValueChangeKindKey] isEqual: @(NSKeyValueChangeSetting)]) {
            NSRunningApplication *app = change[NSKeyValueChangeNewKey];
            if (app) {
                @synchronized (self) {
                    _application = nil;
                    _realBundleId = app.bundleIdentifier;
                }
                [[NSWorkspace sharedWorkspace] removeObserver:self forKeyPath:@"frontmostApplication" context:&_realBundleId];
                self.application.wasActivated = YES;
            }
        }
    }
}
@end
