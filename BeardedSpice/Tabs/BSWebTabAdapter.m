//
//  BSWebTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSWebTabAdapter.h"
#import "BSStrategyWebSocketServer.h"
#import "PSWebSocket.h"
#import "BSTrack.h"
#import "MediaStrategyRegistry.h"
#import "BSMediaStrategy.h"
#import "BSStrategyCache.h"
#import "runningSBApplication.h"

#define RESPONSE_TIMEPUT                        0.2
#define TIMEOUT_WAS_REACHED                     @"TIMEOUT_WAS_REACHED"

static uint _findpid(const struct sockaddr *addr);

@interface PSWebSocket (internal)
- (NSData *)remoteAddress;
@end

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
        [self sendMessage:@"ready"];
    }
    
    return self;
}

- (NSString *)title {
    NSString *result;
    NSDictionary *response = [self sendMessage:@"title"];
    result = response[@"result"];
    if (! [result isKindOfClass:[NSString class]]) {
        result = nil;
    }
    return result;
}

- (NSString *)key {
    
    return _key;
}
- (BOOL)activateApp {
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    
    return [super activateApp];
}

- (BOOL)deactivateApp {
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    return [super deactivateApp];
}

- (BOOL)activateTab {

    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    [super activateTab];
    [self sendMessage:@"activate"];
    return YES;
}

- (BOOL)deactivateTab {
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    
    if ([self frontmost]) {
        if ([self isActivated]) {
            BOOL result = NO;
            NSDictionary *response = [self sendMessage:@"hide"];
            result = [response[@"result"] boolValue];
            [super deactivateTab];
            
            return result;
        }
    }
    return NO;
}

- (BOOL)isActivated {
    
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    
    BOOL result = NO;
    NSDictionary *response = [self sendMessage:@"isActivated"];
    result = [response[@"result"] boolValue];
    
    return result || [super isActivated];
}

- (void)toggleTab {
    BOOL result = [self deactivateTab];
    if (result) {
        [self deactivateApp];
    }
    if (! result) {
        [self activateApp];
        [self activateTab];
    }
}

- (BOOL)frontmost {
    
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    
    BOOL result = NO;
    NSDictionary *response = [self sendMessage:@"frontmost"];
    result = [response[@"result"] boolValue];
    return [super frontmost] && result;
}

- (BOOL)toggle {
    
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    
    NSDictionary *response = [self sendMessage:@"toggle"];
    return [response[@"result"] boolValue];
}
- (BOOL)pause {
    
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    
    NSDictionary *response = [self sendMessage:@"pause"];
    return [response[@"result"] boolValue];
}
- (BOOL)next {

    if (self.application == nil) {
        self.application = [self obtainApplication];
    }

    NSDictionary *response = [self sendMessage:@"next"];
    return [response[@"result"] boolValue];
}
- (BOOL)previous {
    
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }

    NSDictionary *response = [self sendMessage:@"previous"];
    return [response[@"result"] boolValue];
}
- (BOOL)favorite {
    
    NSDictionary *response = [self sendMessage:@"favorite"];
    return [response[@"result"] boolValue];
}

- (BSTrack *)trackInfo {
    
    NSDictionary *response = [self sendMessage:@"trackInfo"];
    return [[BSTrack alloc] initWithInfo:response];
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

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    BS_LOG(LOG_DEBUG, @"%s", __FUNCTION__);
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    BS_LOG(LOG_DEBUG, @"%s", __FUNCTION__);
    
    [BSStrategyWebSocketServer.singleton removeTab:self];
}
- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    BS_LOG(LOG_DEBUG, @"%s\nWebSocket [%p]. Message: %@", __FUNCTION__, webSocket,
           ([message isKindOfClass:[NSData class]]
            ? [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding]
            : message));
    
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
                BS_LOG(LOG_ERROR, @"Bad strategy: %@",strategyName);
            }
            return;
        }
    }
    
    //If we wait response will process it.
    [_actionLock broadcast];
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    BS_LOG(LOG_DEBUG, @"%s", __FUNCTION__);

    [BSStrategyWebSocketServer.singleton removeTab:self];
}

- (void)webSocketDidFlushInput:(PSWebSocket *)webSocket {
    
//    BS_LOG(LOG_DEBUG, @"%s", __FUNCTION__);
}
- (void)webSocketDidFlushOutput:(PSWebSocket *)webSocket {
    
//    BS_LOG(LOG_DEBUG, @"%s", __FUNCTION__);
}
- (BOOL)webSocket:(PSWebSocket *)webSocket evaluateServerTrust:(SecTrustRef)trust {
//    BS_LOG(LOG_DEBUG, @"%s", __FUNCTION__);
    return NO;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

- (id)sendMessage:(id)message {
    id response;
    [_actionLock lock];
    dispatch_async(BSStrategyWebSocketServer.singleton.tabsServer.delegateQueue, ^{
        
        [self.tabSocket send:message];
    });
    if ([_actionLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:RESPONSE_TIMEPUT]] == NO) {
        [NSException exceptionWithName:TIMEOUT_WAS_REACHED reason:nil userInfo:nil];
    }
    if (_lastResponse) {
        response = _lastResponse;
        _lastResponse = nil;
    }
    [_actionLock unlock];
    return response;
}

- (runningSBApplication *)obtainApplication {
    NSString *result;
    @try {
        NSDictionary *response = [self sendMessage:@"bundleId"];
        result = response[@"result"];
        if (! [result isKindOfClass:[NSString class]]) {
            result = nil;
        }
    } @catch (NSException *exception) {
        result = nil;
    }
    return [runningSBApplication sharedApplicationForBundleIdentifier:result];
}

@end

