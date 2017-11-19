//
//  BSBrowserExtensionsController.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.09.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Safari.h"
#import "BSStrategyWebSocketServer.h"

#define APPID_SAFARI            @"com.apple.Safari"
#define APPID_SAFARITP          @"com.apple.SafariTechnologyPreview"

extern NSString *const BSExtensionsResources;

/**
 */
@interface BSBrowserExtensionsController : NSObject

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

+ (BSBrowserExtensionsController *)singleton;

@property (nonatomic, readonly) BSStrategyWebSocketServer *webSocketServer;

- (void)start;
- (void)firstRunPerform;


@end
