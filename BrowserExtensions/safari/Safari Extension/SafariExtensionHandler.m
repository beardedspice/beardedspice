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

@interface SFSafariWindow(internal)
- (void)activateWithCompletionHandler:(void (^)(void))completionHandler;
@end

@implementation SafariExtensionHandler {
    BOOL _wasActivated;
    SFSafariTab *_previousTab;
    SFSafariTab *_previousTabOnNewWindow;
}

+ (void)resetAllTabs {
    NSLog(@"Reset all tabs invoked.");
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

- (void)messageReceivedFromContainingAppWithName:(NSString *)messageName
                                        userInfo:(NSDictionary<NSString *,id> *)userInfo {
    NSLog(@"(BeardedSpice Control) received a message (%@) from app with userInfo (%@)", messageName, userInfo);
    [SafariExtensionHandler resetAllTabs];
}
- (void)messageReceivedWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {
    // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
    [page getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties *properties) {
        NSLog(@"(BeardedSpice Control) received a message (%@) from a script injected into (%@) with userInfo (%@)", messageName, properties.url, userInfo);
        if (properties.url) {
            @autoreleasepool {
                if ([messageName isEqualToString:@"accepters"]) {
                    //request accepters
                    [BSSharedResources acceptersWithCompletion:^(NSDictionary *accepters) {
                        [page dispatchMessageToScriptWithName:@"accepters" userInfo:accepters ?: @{}];
                        NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, accepters);
                    }];
                }
                else if ([messageName isEqualToString:@"port"]) {
                    // request port
                    NSDictionary *response = @{@"result": @(BSSharedResources.tabPort)};
                    [page dispatchMessageToScriptWithName:@"port" userInfo:response];
                    NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                }
                else if ([messageName isEqualToString:@"frontmost"]) {
                    [page getContainingTabWithCompletionHandler:^(SFSafariTab * _Nonnull tab) {
                        [tab getContainingWindowWithCompletionHandler:^(SFSafariWindow * _Nullable window) {
                            [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {
                                if ([activeWindow isEqual:window]) {
                                    // window active
                                    [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
                                        NSDictionary *response = @{@"result": @([activeTab isEqual:tab])};
                                        [page dispatchMessageToScriptWithName:@"frontmost" userInfo:response];
                                        NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                                    }];
                                }
                                else {
                                    NSDictionary *response = @{@"result": @(NO)};
                                    [page dispatchMessageToScriptWithName:@"frontmost" userInfo:response];
                                    NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                                }
                            }];
                        }];
                    }];
                }
                else if ([messageName isEqualToString:@"isActivated"]) {
                    NSDictionary *response = @{@"result": @(properties.active && self->_wasActivated)};
                    [page dispatchMessageToScriptWithName:@"isActivated" userInfo:response];
                    NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                }
                else if ([messageName isEqualToString:@"bundleId"]) {
                    [SFSafariApplication getHostApplicationWithCompletionHandler:^(NSRunningApplication * _Nonnull hostApplication) {
                        NSDictionary *response = @{@"result": hostApplication.bundleIdentifier};
                        [page dispatchMessageToScriptWithName:@"bundleId" userInfo:@{@"result": hostApplication.bundleIdentifier}];
                        NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                    }];
                }
                else if ([messageName isEqualToString:@"serverIsAlive"]) {
                    BOOL running = ([NSRunningApplication runningApplicationsWithBundleIdentifier:BS_BUNDLE_ID].count > 0);
                    if (running && BSSharedResources.tabPort) {
                        NSDictionary *response = @{@"result": @(YES)};
                        [page dispatchMessageToScriptWithName:@"reconnect" userInfo:response];
                        NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                    }
                }
                else if ([messageName isEqualToString:@"activate"]) {
                    [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {
                        [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
                            self->_previousTab = activeTab;
                            [page getContainingTabWithCompletionHandler:^(SFSafariTab * _Nonnull tab) {
                                [tab getContainingWindowWithCompletionHandler:^(SFSafariWindow * _Nullable window) {
                                    [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
                                        self->_previousTabOnNewWindow = activeTab;
                                        if ([self->_previousTabOnNewWindow isEqual:self->_previousTab]) {
                                            self->_previousTabOnNewWindow = nil;
                                        }
                                        [window activateWithCompletionHandler:^{
                                            [tab activateWithCompletionHandler:^{
                                                self->_wasActivated = YES;
                                                NSDictionary *response = @{@"result": @(YES)};
                                                [page dispatchMessageToScriptWithName:@"activate" userInfo:response];
                                                NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }
                else if ([messageName isEqualToString:@"hide"]) {
                    if (properties.active && self->_wasActivated) {
                        void (^activatePreviousTab)(void) = ^void(void) {
                            if (self->_previousTab) {
                                [self->_previousTab activateWithCompletionHandler:^{
                                    NSDictionary *response = @{@"result": @(YES)};
                                    [page dispatchMessageToScriptWithName:@"hide" userInfo:response];
                                    NSLog(@"(BeardedSpice Control) response on '%@': %@", messageName, response);
                                }];
                                self->_previousTab = nil;
                                self->_wasActivated = NO;
                            }
                        };
                        if (self->_previousTabOnNewWindow) {
                            [self->_previousTabOnNewWindow activateWithCompletionHandler:^{
                                activatePreviousTab();
                            }];
                            self->_previousTabOnNewWindow = nil;
                        }
                        else {
                            activatePreviousTab();
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
    NSLog(@"The extension's toolbar item was clicked");
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

//- (BOOL)setMainAppRunning {
//    @synchronized(self) {
//        _mainAppReady = ([NSRunningApplication runningApplicationsWithBundleIdentifier:BS_BUNDLE_ID].count > 0);
//        return _mainAppReady;
//    }
//}

@end
