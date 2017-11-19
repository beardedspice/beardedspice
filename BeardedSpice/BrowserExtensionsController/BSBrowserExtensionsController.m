//
//  BSBrowserExtensionsController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.09.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSBrowserExtensionsController.h"
#import "NSString+Utils.h"
#import "AppDelegate.h"

@implementation BSBrowserExtensionsController {
    
    NSURL *_safariExtensionsPlistUrl;
    NSURL *_safariExtensionPrefPlistUrl;
}

static BSBrowserExtensionsController *singletonBSBrowserExtensionsController;

+ (BSBrowserExtensionsController *)singleton {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonBSBrowserExtensionsController = [BSBrowserExtensionsController alloc];
        
        //redefine this for SafariTechPrev
        singletonBSBrowserExtensionsController = [singletonBSBrowserExtensionsController initWithName:@"Safari"];
    });
    
    return singletonBSBrowserExtensionsController;
}

- (id)init {
    
    
    if (self != singletonBSBrowserExtensionsController) {
        [[NSException exceptionWithName:NSGenericException reason:@"Only singleton!" userInfo:nil] raise];
    }
    
    self = [super init];
    return self;
}

- (id)initWithName:(NSString *)safariName {
    
    if ([NSString isNullOrEmpty:safariName]) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        
        NSError *err;
        NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
        
        if (err) {
            
            NSLog(@"Cannot create application data directory: %@", [err description]);
            [[NSException exceptionWithName:NSGenericException reason:@"Cannot create application data directory" userInfo:nil] raise];
        }
        
        NSString *part = [NSString stringWithFormat:@"%@/Extensions/Extensions.plist", safariName];
        _safariExtensionsPlistUrl = [url URLByAppendingPathComponent:part isDirectory:NO];
        
        part = [NSString stringWithFormat:@"Preferences/com.apple.%@.Extensions.plist", safariName];
        _safariExtensionPrefPlistUrl = [url URLByAppendingPathComponent:part isDirectory:NO];
        
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

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

- (BOOL)installed {

    return NO;
}

@end
