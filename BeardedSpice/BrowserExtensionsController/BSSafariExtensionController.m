//
//  BSSafariExtensionController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.09.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSSafariExtensionController.h"
#import "NSString+Utils.h"

@implementation BSSafariExtensionController {
    
    NSURL *_safariExtensionsPlistUrl;
    NSURL *_safariExtensionPrefPlistUrl;
}

static BSSafariExtensionController *singletonBSSafariExtensionController;

+ (BSSafariExtensionController *)singleton {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonBSSafariExtensionController = [BSSafariExtensionController alloc];
        
        //redefine this for SafariTechPrev
        singletonBSSafariExtensionController = [singletonBSSafariExtensionController initWithName:@"Safari"];
    });
    
    return singletonBSSafariExtensionController;
}

- (id)init {
    
    
    if (self != singletonBSSafariExtensionController) {
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



- (BOOL)installed {

    return NO;
}

@end
