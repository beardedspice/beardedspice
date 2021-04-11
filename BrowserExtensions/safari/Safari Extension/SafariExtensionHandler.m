//
//  SafariExtensionHandler.m
//  Safari Extension
//
//  Created by Roman Sokolov on 29/10/2018.
//  Copyright © 2018  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "SafariExtensionHandler.h"
#import "BSSharedResources.h"
#import <os/lock.h>
#import "EHLDeferBlock.h"

#define SAFARI_PAGES            @"SafariPages"
#define KEY_PTAB                @"previousTab"
#define KEY_PWIN                @"previousWindow"
#define KEY_PTAB_NW             @"previousTabOnNewWindow"

#define WAIT_TIMEOUT            5

@interface SFSafariWindow (internal)
- (NSUUID *)_uuid;
@end
@interface SFSafariTab (internal)
- (NSUUID *)_uuid;
@end


@implementation SafariExtensionHandler {
}

static NSString *_bundleId;
static id _lock;
static BOOL _wasActivated;
static SFSafariTab *_previousTab;
static SFSafariWindow *_previousWindow;
static SFSafariTab *_previousTabOnNewWindow;

+ (void)initialize {
    if (self == [SafariExtensionHandler class]) {
        _lock = [self class];
    }
}

/// Finds window for tab
/// @param completion Called on main thread
- (void)findWindowForTab:(SFSafariTab *)tab completion:(void (^)(SFSafariWindow *window))completion {
    DDLogDebug(@"(BeardedSpice Control) Find window for tab.");
    __block SFSafariWindow *foundedWindow;
    [SFSafariApplication getAllWindowsWithCompletionHandler:^(NSArray<SFSafariWindow *> * _Nonnull windows) {
        EHLDeferBlock *defer = [EHLDeferBlock deferWithCounterValue:windows.count queue:dispatch_get_main_queue() block:^{
            DDLogDebug(@"(BeardedSpice Control) Find window for tab result: %@", [[foundedWindow _uuid] UUIDString]);
            completion(foundedWindow);
        }];
        for (SFSafariWindow *window in windows) {
            [window getAllTabsWithCompletionHandler:^(NSArray<SFSafariTab *> * _Nonnull tabs) {
                if (foundedWindow == nil) {
                    for (SFSafariTab *item in tabs) {
                        if ([tab isEqual:item]) {
                            foundedWindow = window;
                            break;
                        }
                    }
                }
                [defer count];
            }];
        }
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [BSSharedResources initLoggerFor:BS_SAFARI_EXTENSION_BUNDLE_ID];
    }
    return self;
}

- (void)messageReceivedFromContainingAppWithName:(NSString *)messageName
                                        userInfo:(NSDictionary<NSString *,id> *)userInfo {
    DDLogDebug(@"(BeardedSpice Control) received a message (%@) from app with userInfo (%@)", messageName, userInfo);
}
- (void)messageReceivedWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {
    // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
    if (_bundleId.length){
        [self processMessageWithName:messageName fromPage:page userInfo:userInfo];
    }
    else {
        [SFSafariApplication getHostApplicationWithCompletionHandler:^(NSRunningApplication * _Nonnull hostApplication) {
            @synchronized (_lock) {
                if (!_bundleId.length) {
                // if this thread defined bundleId
                    _bundleId = hostApplication.bundleIdentifier;
                    DDLogDebug(@"(BeardedSpice Control) BundleId: %@", _bundleId);
                    [SafariExtensionHandler restoreSettings];
                }
            }
            
            [self processMessageWithName:messageName fromPage:page userInfo:userInfo];
        }];
    }
}

- (void)toolbarItemClickedInWindow:(SFSafariWindow *)window {
    // This method will be called when your toolbar item is clicked.
    DDLogDebug(@"(BeardedSpice Control) The extension's toolbar item was clicked");
}

- (void)validateToolbarItemInWindow:(SFSafariWindow *)window validationHandler:(void (^)(BOOL enabled, NSString *badgeText))validationHandler {
    // This method will be called whenever some state changes in the passed in window. You should use this as a chance to enable or disable your toolbar item and set badge text.
    validationHandler(YES, nil);
}

- (SFSafariExtensionViewController *)popoverViewController {
    return nil;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Main PROCESSING

- (void)processMessageWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {

    [page getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties *properties) {
        DDLogDebug(@"(BeardedSpice Control) received a message (%@) from a script injected into (%@) (page state: %@) with userInfo (%@)", messageName, properties.url, (properties.active ? @"active" : @"disactive"), userInfo);
        if (properties.url) {
            @autoreleasepool {
                
                if ([messageName isEqualToString:@"accepters"]) {
                    //request accepters
                    [BSSharedResources acceptersWithCompletion:^(NSDictionary *accepters) {
                        [page dispatchMessageToScriptWithName:@"accepters" userInfo:accepters ?: @{}];
                        DDLogDebug(@"(BeardedSpice Control) response on '%@': %@", messageName, accepters);
                    }];
                }
                else if ([messageName isEqualToString:@"port"]) {
                    // request port
                    NSDictionary *response = @{@"result": @(BSSharedResources.tabPort)};
                    [page dispatchMessageToScriptWithName:@"port" userInfo:response];
                    DDLogDebug(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                }
                else if ([messageName isEqualToString:@"frontmost"]) {
                    [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {

                        if (activeWindow == nil) {
                            [self send:page result:NO of:@"frontmost"];
                        }

                        [page getContainingTabWithCompletionHandler:^(SFSafariTab * _Nonnull tab) {

                            if (tab == nil) {
                                [self send:page result:NO of:@"frontmost"];
                            }

                            [tab getContainingWindowWithCompletionHandler:^(SFSafariWindow * _Nullable window) {
                                if (window == nil || [activeWindow isEqual:window]) {
                                    // window active
                                    [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
                                        [self send:page result:[activeTab isEqual:tab] of:@"frontmost"];
                                    }];
                                }
                                else {
                                    [self send:page result:NO of:@"frontmost"];
                                }
                            }];
                        }];
                    }];
                }
                else if ([messageName isEqualToString:@"isActivated"]) {
                    @synchronized (_lock) {
                        DDLogDebug(@"(BeardedSpice Control) response on '%@': act-%d, wasAct-%d", messageName, properties.active, _wasActivated);
                        
                        [self send:page result:(properties.active && _wasActivated) of:@"isActivated"];
                    }
                }
                else if ([messageName isEqualToString:@"bundleId"]) {
                    NSDictionary *response = @{@"result": _bundleId ?: BS_DEFAULT_SAFARI_BUBDLE_ID};
                    [page dispatchMessageToScriptWithName:@"bundleId" userInfo:response];
                    DDLogDebug(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                }
                else if ([messageName isEqualToString:@"serverIsAlive"]) {
                    BOOL running = ([NSRunningApplication runningApplicationsWithBundleIdentifier:BS_BUNDLE_ID].count > 0);
                    [self send:page result:(running && BSSharedResources.tabPort != 0) of:@"serverIsAlive"];
                }
                else if ([messageName isEqualToString:@"activate"]) {
                    [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {
                        if (activeWindow == nil) {
                            [self send:page result:NO of:@"activate"];
                        }

                        DDLogDebug(@"(BeardedSpice Control) SFSafariApplication getActiveWindowWithCompletionHandler: %@", [[activeWindow _uuid] UUIDString]);
                        [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
                            DDLogDebug(@"(BeardedSpice Control) activeWindow getActiveTabWithCompletionHandler: %@", [[activeTab _uuid] UUIDString]);
                                [page getContainingTabWithCompletionHandler:^(SFSafariTab * _Nonnull tab) {
                                    if (tab == nil) {
                                        [self send:page result:NO of:@"activate"];
                                    }

                                    DDLogDebug(@"(BeardedSpice Control) page getContainingTabWithCompletionHandler: %@", [[tab _uuid] UUIDString]);
                                    [tab getContainingWindowWithCompletionHandler:^(SFSafariWindow * _Nullable window) {
                                        if (window == nil) {
                                            [self findWindowForTab:tab completion:^(SFSafariWindow *window) {
                                                if (window == nil) {
                                                    [self send:page result:NO of:@"activate"];
                                                    return;
                                                }
                                                [self activateTabContinueWithPage:page
                                                                              tab:tab
                                                                           window:window
                                                                        activeTab:activeTab
                                                                     activeWindow:activeWindow];
                                            }];
                                        }
                                        else {
                                            [self activateTabContinueWithPage:page
                                                                          tab:tab
                                                                       window:window
                                                                    activeTab:activeTab
                                                                 activeWindow:activeWindow];
                                        }
                                    }];
                                }];
                        }];
                    }];
                }
                else if ([messageName isEqualToString:@"hide"]) {
                    @synchronized (_lock) {
                        if (properties.active && _wasActivated) {
                            void (^activatePreviousTab)(void) = ^void(void) {
                                @synchronized (_lock) {
                                    if (_previousTab) {
                                        NSString *uuid = [(NSUUID *)[_previousWindow _uuid] UUIDString];
                                        [_previousTab activateWithCompletionHandler:^{
                                            if (uuid.length) {
                                                NSDictionary *response = @{
                                                    @"result": @(YES),
                                                    @"windowIdForMakeFrontmost": uuid
                                                };
                                                [page dispatchMessageToScriptWithName:@"hide" userInfo:response];
                                                DDLogDebug(@"(BeardedSpice Control) response on '%@': %@", @"hide", response);
                                            }
                                            [self send:page result:YES of:@"hide"];
                                        }];
                                        _previousTab = nil;
                                        _previousWindow = nil;
                                        _wasActivated = NO;
                                    }
                                }
                            };
                            if (_previousTabOnNewWindow) {
                                [_previousTabOnNewWindow activateWithCompletionHandler:^{
                                    activatePreviousTab();
                                }];
                                _previousTabOnNewWindow = nil;
                            }
                            else {
                                activatePreviousTab();
                            }
                            [SafariExtensionHandler saveSettings];
                        }
                        else {
                            [self send:page result:NO of:@"hide"];
                        }
                    }
                }
            }
        }
    }];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods

+ (void)restoreSettings {
    if (! _bundleId.length) {
        return;
    }
    NSString *key = [@"BSSettings_" stringByAppendingString:_bundleId];
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSData *obj = settings[KEY_PTAB];
    if (obj) {
        _previousTab = [NSKeyedUnarchiver unarchivedObjectOfClass:[SFSafariTab class]
                                                         fromData:obj
                                                            error:NULL];
    }
    obj = settings[KEY_PTAB_NW];
    if (obj) {
        _previousTabOnNewWindow = [NSKeyedUnarchiver unarchivedObjectOfClass:[SFSafariTab class]
                                                                    fromData:obj
                                                                       error:NULL];
    }
    obj = settings[KEY_PWIN];
    if (obj) {
        _previousWindow = [NSKeyedUnarchiver unarchivedObjectOfClass:[SFSafariWindow class]
                                                                    fromData:obj
                                                                       error:NULL];
    }
}

+ (void)saveSettings {
    
    if (! _bundleId.length) {
        return;
    }
    NSString *key = [@"BSSettings_" stringByAppendingString:_bundleId];
    NSData *previousTab = [NSKeyedArchiver archivedDataWithRootObject:_previousTab
                                                requiringSecureCoding:YES
                                                                error:NULL] ?: [NSData data];
    NSData *previousWindow = [NSKeyedArchiver archivedDataWithRootObject:_previousWindow
                                                requiringSecureCoding:YES
                                                                error:NULL] ?: [NSData data];
    
    NSData *previousTabOnNewWindow = [NSKeyedArchiver archivedDataWithRootObject:_previousTabOnNewWindow
                                                           requiringSecureCoding:YES
                                                                           error:NULL] ?: [NSData data];
    
    NSDictionary *settings = @{
                               KEY_PTAB: previousTab,
                               KEY_PTAB_NW: previousTabOnNewWindow,
                               KEY_PWIN: previousWindow
                               };
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:key];
}
- (void)send:(SFSafariPage *)page result:(BOOL)result of:(NSString *)of {
    NSDictionary *response = @{@"result": @(result)};
    [page dispatchMessageToScriptWithName:of userInfo:response];
    DDLogDebug(@"(BeardedSpice Control) response on '%@': %@", of, response);
}

- (void)activateTabContinueWithPage:(SFSafariPage *)page
                                tab:(SFSafariTab *)tab
                             window:(SFSafariWindow *)window
                          activeTab:(SFSafariTab *)activeTab
                       activeWindow:(SFSafariWindow *)activeWindow {
    
    DDLogDebug(@"(BeardedSpice Control) tab getContainingWindowWithCompletionHandler: %@", [[window _uuid] UUIDString]);
    [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTabOnNewWindow) {
        DDLogDebug(@"(BeardedSpice Control) window getActiveTabWithCompletionHandler: %@", [[activeTabOnNewWindow _uuid] UUIDString]);
        @synchronized (_lock) {
            _previousTab = activeTab;
            _previousWindow = activeWindow;
            _previousTabOnNewWindow = activeTabOnNewWindow;
            if ([activeWindow isEqualTo:window]) {
                _previousWindow =  nil;
            }
            if ([_previousTabOnNewWindow isEqual:_previousTab]) {
                _previousTabOnNewWindow = nil;
            }
            [SafariExtensionHandler saveSettings];
        }
        [tab activateWithCompletionHandler:^{
            @synchronized (_lock) {
                _wasActivated = YES;
            }
            NSString *uuid = _previousWindow ? [[window _uuid] UUIDString] : nil;
            if (uuid.length) {
                NSDictionary *response = @{
                    @"result": @(YES),
                    @"windowIdForMakeFrontmost": uuid
                };
                [page dispatchMessageToScriptWithName:@"activate" userInfo:response];
                DDLogDebug(@"(BeardedSpice Control) response on '%@': %@", @"activate", response);
            }
            else {
                [self send:page result:YES of:@"activate"];
            }
        }];
    }];

}
@end
