//
//  BSWebTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSWebTabAdapter.h"
#import "BSStrategyWebSocketServer.h"

@implementation BSWebTabAdapter {
    
    NSString *_key;
}

- (id)initWithBrowserSocket:(PSWebSocket *)browserSocket {
    
    if (browserSocket == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
     
        _browserSocket = browserSocket;
        _key = [[NSUUID UUID] UUIDString];
    }
    
    return self;
}

- (NSString *)title {
    
    return [BSStrategyWebSocketServer.singleton title:self];
}

- (NSString *)key {
    
    return _key;
}
//- (BOOL)check {
//    
//}

- (void)activateTab {

    [super activateTab];
    [BSStrategyWebSocketServer.singleton activateTab:self];
}

- (BOOL)isActivated {
    
    return [super isActivated] && [BSStrategyWebSocketServer.singleton isActivated:self];
}

- (void)toggleTab {
    
    [super toggleTab];
}
- (BOOL)frontmost {
    
    return [super frontmost] && [BSStrategyWebSocketServer.singleton frontmost:self];
}

- (void)toggle {
    
    [BSStrategyWebSocketServer.singleton toggle:self];
}
- (void)pause {
    
    [BSStrategyWebSocketServer.singleton pause:self];
}
- (void)next {
    
    [BSStrategyWebSocketServer.singleton next:self];
}
- (void)previous {
    
    [BSStrategyWebSocketServer.singleton previous:self];
}
- (void)favorite {
    
    [BSStrategyWebSocketServer.singleton favorite:self];
}

- (BSTrack *)trackInfo {
    
    return [BSStrategyWebSocketServer.singleton trackInfo:self];
}

- (BOOL)isPlaying {
    
    return [BSStrategyWebSocketServer.singleton isPlaying:self];
}

///**
// Copying of the variables, which reflect state of the object.
// 
// @param tab Object from which performed copying.
// 
// @return Returns self.
// */
//- (instancetype)copyStateFrom:(TabAdapter *)tab;
//
//-(BOOL) isEqual:(__autoreleasing id)otherTab;
//

@end
