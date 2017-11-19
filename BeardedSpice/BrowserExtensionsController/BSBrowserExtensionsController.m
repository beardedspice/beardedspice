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

#define SAFARI_EXTENSION_NAME                           @"BeardedSpice.safariextz"
#define CURRENT_VERSION_MARKER                          @"cerrentExtensionVersion.txt"

NSString *const BSExtensionsResources = @"ExtensionsResources";

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
            [self initSafariextz];
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

- (void)firstRunPerform {
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
        
    };
    
    [APPDELEGATE removeWindow:alert];

}

/////////////////////////////////////////////////////////////////////////
#pragma mark Helper methods (Private)

- (void)initSafariextz {
    
    NSURL *versionUrl = [[NSURL URLForSafariExtensionResources] URLByAppendingPathComponent:CURRENT_VERSION_MARKER];
    if (versionUrl) {
        NSString *version = [NSString stringWithContentsOfURL:versionUrl encoding:NSUTF8StringEncoding error:NULL];
        if ([NSString isNullOrEmpty:version]
            || ! [version isEqualToString:BS_SAFARI_EXTENSION_VERSION]) {
            //Condition for copying extension file to resources folder
            NSURL *safariExtFromUrl = [[NSBundle mainBundle] URLForResource:SAFARI_EXTENSION_NAME withExtension:nil subdirectory:BSExtensionsResources];
            NSURL *safariExtToUrl = [[NSURL URLForSafariExtensionResources] URLByAppendingPathComponent:SAFARI_EXTENSION_NAME];
            NSError *error = nil;
            if ([safariExtToUrl fileExists]) {
                [[NSFileManager defaultManager] removeItemAtURL:safariExtToUrl error:&error];
                if (error) {
                    BS_LOG(LOG_ERROR, @"Error occures when Safari Extension file is removed: %@", error.description);
                    error = nil;
                }
            }
            if ([[NSFileManager defaultManager] copyItemAtURL:safariExtFromUrl toURL:safariExtToUrl error:&error] == NO) {
                BS_LOG(LOG_CRITICAL, @"Can't copy Safari Extension file: %@", error.description);
                [[NSException appResourceUnavailableException:SAFARI_EXTENSION_NAME] raise];
            }
            
            if ([BS_SAFARI_EXTENSION_VERSION writeToURL:versionUrl atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
                BS_LOG(LOG_CRITICAL, @"Can't save version marker for Safari Extension: %@", error.description);
                [[NSException appResourceUnavailableException:versionUrl.description] raise];
            }
        }
    }
}

@end
