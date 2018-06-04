//
//  BSBrowserExtensionsController.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.09.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSStrategyWebSocketServer.h"

#define APPID_SAFARI            @"com.apple.Safari"
#define APPID_SAFARITP          @"com.apple.SafariTechnologyPreview"
#define APPID_CHROME            @"com.google.Chrome"

/////////////////////////////////////////////////////////////////////////
#pragma mark Constants
extern NSString *const BSSafariExtensionName;
extern NSString *const BSGetExtensionsPageName;
/**
 */
@interface BSBrowserExtensionsController : NSObject

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

+ (BSBrowserExtensionsController *)singleton;

@property (nonatomic, readonly) BSStrategyWebSocketServer *webSocketServer;

- (void)start;
- (void)firstRunPerformWithCompletion:(dispatch_block_t)completion;
- (void)openGetExtensions;

@end
