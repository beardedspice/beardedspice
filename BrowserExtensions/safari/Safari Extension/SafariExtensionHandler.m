//
//  SafariExtensionHandler.m
//  Safari Extension
//
//  Created by Roman Sokolov on 29/10/2018.
//  Copyright © 2018 BeardedSpice. All rights reserved.
//

#import "SafariExtensionHandler.h"
#import "BSSharedResources.h"
#import <os/lock.h>
#import "EHLDeferBlock.h"

#define SAFARI_PAGES            @"SafariPages"
#define KEY_PTAB                @"previousTab"
#define KEY_PTAB_NW             @"previousTabOnNewWindow"

@implementation SafariExtensionHandler

static NSString *_bundleId;
static id _lock;
static BOOL _wasActivated;
static SFSafariTab *_previousTab;
static SFSafariTab *_previousTabOnNewWindow;

+ (void)initialize {
    if (self == [SafariExtensionHandler class]) {
        _lock = [self class];
        [SFSafariApplication getHostApplicationWithCompletionHandler:^(NSRunningApplication * _Nonnull hostApplication) {
            _bundleId = hostApplication.bundleIdentifier ?: BS_DEFAULT_SAFARI_BUBDLE_ID;
            BS_LOG(LOG_DEBUG, @"(BeardedSpice Control) BundleId: %@", _bundleId);
        }];
        [self restoreSettings];
    }
}

+ (void)resetAllTabs {
    BS_LOG(LOG_DEBUG,@"Reset all tabs invoked.");
    [SFSafariApplication getAllWindowsWithCompletionHandler:^(NSArray<SFSafariWindow *> * _Nonnull windows) {
        for (SFSafariWindow *window in windows) {
            [window getAllTabsWithCompletionHandler:^(NSArray<SFSafariTab *> * _Nonnull tabs) {

                for (SFSafariTab *tab in tabs) {
                    [tab getPagesWithCompletionHandler:^(NSArray<SFSafariPage *> * _Nullable pages) {
                        for (SFSafariPage *page in pages) {
                            [page dispatchMessageToScriptWithName:@"reconnect"
                                                         userInfo:@{@"result": @(YES)}];
                        }
                    }];
                }
            }];
        }
    }];
}
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

//- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
//    if (!_bundleId.length) {
//        _bundleId = BS_DEFAULT_SAFARI_BUBDLE_ID;
//        BS_LOG(LOG_DEBUG, @"(BeardedSpice Control) Safari Bundleid!!!");
//    }
//}

- (void)messageReceivedFromContainingAppWithName:(NSString *)messageName
                                        userInfo:(NSDictionary<NSString *,id> *)userInfo {
    BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) received a message (%@) from app with userInfo (%@)", messageName, userInfo);
    if ([messageName isEqualToString:@"reconnect"]) {
        [SafariExtensionHandler resetAllTabs];
    }
}
- (void)messageReceivedWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {
    // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
    [page getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties *properties) {
        BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) received a message (%@) from a script injected into (%@) (page state: %@) with userInfo (%@)", messageName, properties.url, (properties.active ? @"active" : @"disactive"), userInfo);
        if (properties.url) {
            @autoreleasepool {
                if ([messageName isEqualToString:@"accepters"]) {
                    //request accepters
                    [BSSharedResources acceptersWithCompletion:^(NSDictionary *accepters) {
                        [page dispatchMessageToScriptWithName:@"accepters" userInfo:accepters ?: @{}];
                        BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) response on '%@': %@", messageName, accepters);
                    }];
                }
                else if ([messageName isEqualToString:@"port"]) {
                    // request port
                    NSDictionary *response = @{@"result": @(BSSharedResources.tabPort)};
                    [page dispatchMessageToScriptWithName:@"port" userInfo:response];
                    BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) response on '%@': %@", messageName, response);
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
                        BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) response on '%@': act-%d, wasAct-%d", messageName, properties.active, _wasActivated);
                        
                        [self send:page result:(properties.active && _wasActivated) of:@"isActivated"];
                    }
                }
                else if ([messageName isEqualToString:@"bundleId"]) {
                    NSDictionary *response = @{@"result": _bundleId};
                    [page dispatchMessageToScriptWithName:@"bundleId" userInfo:response];
                    BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                }
                else if ([messageName isEqualToString:@"serverIsAlive"]) {
                    BOOL running = ([NSRunningApplication runningApplicationsWithBundleIdentifier:BS_BUNDLE_ID].count > 0);
                    if (running && BSSharedResources.tabPort) {
                        [self send:page result:YES of:@"reconnect"];
                    }
                }
                else if ([messageName isEqualToString:@"activate"]) {
                    [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {
                        if (activeWindow == nil) {
                            [self send:page result:NO of:@"activate"];
                        }

                        BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) SFSafariApplication getActiveWindowWithCompletionHandler: %@", activeWindow);
                        [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
                            BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) activeWindow getActiveTabWithCompletionHandler: %@", activeTab);
                                [page getContainingTabWithCompletionHandler:^(SFSafariTab * _Nonnull tab) {
                                    if (tab == nil) {
                                        [self send:page result:NO of:@"activate"];
                                    }

                                    BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) page getContainingTabWithCompletionHandler: %@", tab);
                                    [tab getContainingWindowWithCompletionHandler:^(SFSafariWindow * _Nullable window) {
                                        if (window == nil) {
                                            window = activeWindow;
                                        }
                                        BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) tab getContainingWindowWithCompletionHandler: %@", window);
                                        [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTabOnNewWindow) {
                                            BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) window getActiveTabWithCompletionHandler: %@", activeTabOnNewWindow);
                                            @synchronized (_lock) {
                                                _previousTab = activeTab;
                                                _previousTabOnNewWindow = activeTabOnNewWindow;
                                                if ([_previousTabOnNewWindow isEqual:_previousTab]) {
                                                    _previousTabOnNewWindow = nil;
                                                }
                                                [SafariExtensionHandler saveSettings];
                                            }
                                            [tab activateWithCompletionHandler:^{
                                                @synchronized (_lock) {
                                                    _wasActivated = YES;
                                                }
                                                [self send:page result:YES of:@"activate"];
                                            }];
                                        }];
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
                                        [_previousTab activateWithCompletionHandler:^{
                                            [self send:page result:YES of:@"hide"];
                                        }];
                                        _previousTab = nil;
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
                //                    else if ([messageName isEqualToString:@"pairing"]) {
                //                        BSUtils.storageSet("hostBundleId", theMessageEvent.message.bundleId, () => {
                //                            BSUtils.sendMessageToTab(theMessageEvent.target, "pairing", { 'result': true });
                //                        });
                //                        }
            }
        }
    }];
}

- (void)toolbarItemClickedInWindow:(SFSafariWindow *)window {
    // This method will be called when your toolbar item is clicked.
    BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) The extension's toolbar item was clicked");
}

- (void)validateToolbarItemInWindow:(SFSafariWindow *)window validationHandler:(void (^)(BOOL enabled, NSString *badgeText))validationHandler {
    // This method will be called whenever some state changes in the passed in window. You should use this as a chance to enable or disable your toolbar item and set badge text.
    validationHandler(YES, nil);
}

- (SFSafariExtensionViewController *)popoverViewController {
    return nil;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods

+ (void)restoreSettings {
    if (! _bundleId.length) {
        return;
    }
    NSString *key = [@"BSSettings_" stringByAppendingString:_bundleId];
    NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    NSData *tab = settings[KEY_PTAB];
    if (tab) {
        _previousTab = [NSKeyedUnarchiver unarchivedObjectOfClass:[SFSafariTab class]
                                                         fromData:tab
                                                            error:NULL];
    }
    tab = settings[KEY_PTAB_NW];
    if (tab) {
        _previousTabOnNewWindow = [NSKeyedUnarchiver unarchivedObjectOfClass:[SFSafariTab class]
                                                                    fromData:tab
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
    NSData *previousTabOnNewWindow = [NSKeyedArchiver archivedDataWithRootObject:_previousTabOnNewWindow
                                                           requiringSecureCoding:YES
                                                                           error:NULL] ?: [NSData data];
    
    NSDictionary *settings = @{
                               KEY_PTAB: previousTab,
                               KEY_PTAB_NW: previousTabOnNewWindow
                               };
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:key];
}
- (void)send:(SFSafariPage *)page result:(BOOL)result of:(NSString *)of {
    NSDictionary *response = @{@"result": @(result)};
    [page dispatchMessageToScriptWithName:of userInfo:response];
    BS_LOG(LOG_DEBUG,@"(BeardedSpice Control) response on '%@': %@", of, response);
}

@end
