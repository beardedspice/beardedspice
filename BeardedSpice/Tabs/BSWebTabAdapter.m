//
//  BSWebTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSWebTabAdapter.h"
#import "BSStrategyWebSocketServer.h"
#import <PSWebSocket.h>
#import "BSTrack.h"
#import "MediaStrategyRegistry.h"
#import "BSMediaStrategy.h"
#import "BSStrategyCache.h"

#define RESPONSE_TIMEPUT                    0.1

@implementation BSWebTabAdapter {
    
    NSString *_key;
    NSCondition *_actionLock;
    NSDictionary *_lastResponse;
}

- (id)initWithBrowserSocket:(PSWebSocket *)tabSocket {
    
    if (tabSocket == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
     
        _tabSocket = tabSocket;
        _tabSocket.delegate = self;
        _key = [[NSUUID UUID] UUIDString];
        _actionLock = [NSCondition new];
    }
    
    return self;
}

- (NSString *)title {
    
    NSDictionary *response = [self sendMessage:@"title"];
    return response[@"result"];
}

- (NSString *)key {
    
    return _key;
}
//- (BOOL)check {
//    
//}

- (void)activateTab {

    [super activateTab];
    [self sendMessage:@"activate"];
}

- (BOOL)isActivated {
    
    NSDictionary *response = [self sendMessage:@"isActivated"];
    BOOL result = [response[@"result"] boolValue];
    return [super isActivated] && result;
}

- (void)toggleTab {
    
//    [super toggleTab];
}
- (BOOL)frontmost {
    
    NSDictionary *response = [self sendMessage:@"frontmost"];
    BOOL result = [response[@"result"] boolValue];
    return [super frontmost] && result;
}

- (BOOL)toggle {
    
    NSDictionary *response = [self sendMessage:@"toggle"];
    return [response[@"result"] boolValue];
}
- (BOOL)pause {
    
    NSDictionary *response = [self sendMessage:@"pause"];
    return [response[@"result"] boolValue];
}
- (BOOL)next {
    
    NSDictionary *response = [self sendMessage:@"next"];
    return [response[@"result"] boolValue];
}
- (BOOL)previous {
    
    NSDictionary *response = [self sendMessage:@"previous"];
    return [response[@"result"] boolValue];
}
- (BOOL)favorite {
    
    NSDictionary *response = [self sendMessage:@"favorite"];
    return [response[@"result"] boolValue];
}

- (BSTrack *)trackInfo {
    
    NSDictionary *response = [self sendMessage:@"trackInfo"];
    BSTrack *trackInfo = [[BSTrack alloc] initWithInfo:response];
    return trackInfo;
}

- (BOOL)isPlaying {
    
    NSDictionary *response = [self sendMessage:@"isPlaying"];
    return [response[@"result"] boolValue];
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

/////////////////////////////////////////////////////////////////////////
#pragma mark PSWebSocketDelegate delegates

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    NSLog(@"%s", __FUNCTION__);
    
    [BSStrategyWebSocketServer.singleton removeTab:self];
}
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSLog(@"%s", __FUNCTION__);
    NSData *messageData = [message isKindOfClass:[NSString class]] ?
    [message dataUsingEncoding:NSUTF8StringEncoding]
    : message;
    
    _lastResponse = [NSJSONSerialization JSONObjectWithData:messageData options:0 error:NULL];
    if (_lastResponse) {
        
        //Check if this is strategy request
        NSString *strategyName = _lastResponse[@"strategy"];
        if (strategyName) {
            //getting current strategy
            _strategy = MediaStrategyRegistry.singleton.strategyCache.cache[strategyName];
            //sending to client
            if (_strategy.strategyJsBody) {
                [self sendMessage:_strategy.strategyJsBody];
            }
            else {
                NSLog(@"Bad strategy");
            }
            return;
        }
    }
    
    //If we wait response will process it.
    [_actionLock broadcast];
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    NSLog(@"%s", __FUNCTION__);
    
    [BSStrategyWebSocketServer.singleton removeTab:self];
}

//- (void)webSocketDidFlushInput:(PSWebSocket *)webSocket;
//- (void)webSocketDidFlushOutput:(PSWebSocket *)webSocket;
//- (BOOL)webSocket:(PSWebSocket *)webSocket evaluateServerTrust:(SecTrustRef)trust;

/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

- (id)sendMessage:(id)message {
    id response;
    [_actionLock lock];
    dispatch_async(BSStrategyWebSocketServer.singleton.tabsServer.delegateQueue, ^{
        
        [self.tabSocket send:message];
    });
    [_actionLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:RESPONSE_TIMEPUT]];
    if (_lastResponse) {
        response = _lastResponse;
        _lastResponse = nil;
    }
    [_actionLock unlock];
    return response;
}
@end
