//
//  BSStrategyWebSocketServer.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSWebSocketServer.h"

@class BSWebTabAdapter, BSTrack;

@interface BSStrategyWebSocketServer : NSObject <PSWebSocketServerDelegate>

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

+ (BSStrategyWebSocketServer *)singleton;

@property (nonatomic, readonly) PSWebSocketServer *server;
@property (nonatomic,readonly) uint16_t port;

- (void)start;
- (void)stop;

- (BOOL)frontmost:(BSWebTabAdapter *)tab;

- (BOOL)isActivated:(BSWebTabAdapter *)tab;
- (void)toggleTab:(BSWebTabAdapter *)tab;
- (void)activateTab:(BSWebTabAdapter *)tab;

- (NSString *)title:(BSWebTabAdapter *)tab;

- (void)toggle:(BSWebTabAdapter *)tab;
- (void)pause:(BSWebTabAdapter *)tab;
- (void)next:(BSWebTabAdapter *)tab;
- (void)previous:(BSWebTabAdapter *)tab;
- (void)favorite:(BSWebTabAdapter *)tab;

- (BSTrack *)trackInfo:(BSWebTabAdapter *)tab;
- (BOOL)isPlaying:(BSWebTabAdapter *)tab;

@end
