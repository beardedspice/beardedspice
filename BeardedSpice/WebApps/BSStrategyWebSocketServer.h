//
//  BSStrategyWebSocketServer.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
#import "PSWebSocketServer.h"
#import "BSWebTabAdapter.h"
#import "BSWebTabSafariAdapter.h"
#import "BSWebTabChromeAdapter.h"

@class BSTrack;

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications
extern NSString *const BSWebSocketServerStartedNotification;

/////////////////////////////////////////////////////////////////////////
#pragma mark - BSStrategyWebSocketServer

@interface BSStrategyWebSocketServer : NSObject <PSWebSocketServerDelegate>

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

+ (BSStrategyWebSocketServer *)singleton;

@property (nonatomic, readonly) PSWebSocketServer *tabsServer;
@property (nonatomic,readonly) uint16_t tabsPort;
@property (nonatomic, readonly) BOOL started;

- (BOOL)start;
/**
 Stops server.

 @param completion Block, which is performed on main queue when server stopped. May be nil.
 */
- (void)stopWithComletion:(void (^)(void))completion;

- (NSArray <BSWebTabAdapter *> *)tabs;
- (void)removeTab:(BSWebTabAdapter *)tab;

@end
