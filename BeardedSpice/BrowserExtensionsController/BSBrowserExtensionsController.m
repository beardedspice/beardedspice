//
//  BSBrowserExtensionsController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.09.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSBrowserExtensionsController.h"
#import "NSString+Utils.h"
#import "NSURL+Utils.h"
#import "NSException+Utils.h"
#import "AppDelegate.h"
#import "GeneralPreferencesViewController.h"


NSString *const BSSafariExtensionName = @"/BeardedSpice.safariextz";
NSString *const BSGetExtensionsPageName = @"/get-extensions.html";

#define URL_FORMAT                                      @"https://localhost:%d%@"

@implementation BSBrowserExtensionsController {
    NSMutableArray *_observers;
    dispatch_queue_t _workQueue;
    NSOperationQueue *_oQueue;
    BOOL _started;
}

static BSBrowserExtensionsController *singletonBSBrowserExtensionsController;

+ (BSBrowserExtensionsController *)singleton {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonBSBrowserExtensionsController = [BSBrowserExtensionsController alloc];
        
        //redefine this for SafariTechPrev
        singletonBSBrowserExtensionsController = [singletonBSBrowserExtensionsController init];
    });
    
    return singletonBSBrowserExtensionsController;
}

- (id)init {
    
    
    if (self != singletonBSBrowserExtensionsController) {
        [[NSException exceptionWithName:NSGenericException reason:@"Only singleton!" userInfo:nil] raise];
    }
    
    self = [super init];
    if (self) {
        _started = NO;
        _observers = [NSMutableArray new];
        _workQueue = dispatch_queue_create("BrowserExtensionsController", DISPATCH_QUEUE_SERIAL);
        _webSocketServer = [BSStrategyWebSocketServer singleton];
    }
    return self;
}

- (void)dealloc {
    for (id item in _observers) {
        [[NSNotificationCenter defaultCenter] removeObserver:item];
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

- (void)start {
    dispatch_async(_workQueue, ^{
        if (! _started) {
            _oQueue = [NSOperationQueue new];
            _oQueue.underlyingQueue = _workQueue;
            id observer = [[NSNotificationCenter defaultCenter]
                           addObserverForName:GeneralPreferencesWebSocketServerEnabledChangedNoticiation
                           object:nil queue:_oQueue usingBlock:^(NSNotification * _Nonnull note) {
                               @autoreleasepool {
                                   if ([[NSUserDefaults standardUserDefaults] boolForKey:BSWebSocketServerEnabled]) {
                                       [_webSocketServer start];
                                   }
                                   else {
                                       [_webSocketServer stopWithComletion:nil];
                                   }
                               }
                           }];
            if (observer) {
                [_observers addObject:observer];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:BSWebSocketServerEnabled]) {
                [_webSocketServer start];
            }
            _started = YES;
        }
    });
}

- (void)openGetExtensions {
    if (_webSocketServer.started == NO) {
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:URL_FORMAT, _webSocketServer.controlPort, BSGetExtensionsPageName]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}
- (void)firstRunPerformWithCompletion:(dispatch_block_t)completion {

    ASSIGN_WEAK(self);
    ASSIGN_WEAK(completion);
    
    __block id observer;
    dispatch_block_t execBlock = ^() {
        @autoreleasepool {
            ASSIGN_STRONG(self);
            ASSIGN_STRONG(completion);
            
            if (observer) {
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
                observer = nil;
            }
            
            NSAlert *alert = [NSAlert new];
            alert.alertStyle = NSWarningAlertStyle;
            alert.messageText = NSLocalizedString(@"Install Browser Extension", @"Title of the suggestion about installing BeardedSpice extensions for browsers.");
            alert.informativeText = NSLocalizedString(@"In order to manage the media players on supported sites, it is necessary to install the BeardedSpice browser extension.", @"Informative text of the suggestion about installing BeardedSpice extensions for browsers.");
            [alert addButtonWithTitle:NSLocalizedString(@"Get Extensions...",
                                                        @"Button title")];
            
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel",
                                                        @"Button title")];
            
            [APPDELEGATE windowWillBeVisible:alert];
            
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                [USE_STRONG(self) openGetExtensions];
            };
            if (USE_STRONG(completion)) {
                USE_STRONG(completion)();
            }

            [APPDELEGATE removeWindow:alert];
        }
    };
    
    if (_webSocketServer.started == NO) {
        observer = [[NSNotificationCenter defaultCenter]
                    addObserverForName:BSWebSocketServerStartedNotification
                    object:nil queue:_oQueue usingBlock:^(NSNotification * _Nonnull note) {
                        dispatch_async(dispatch_get_main_queue(), execBlock);
                    }];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), execBlock);
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods (Private)

@end
