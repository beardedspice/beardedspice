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

#define RESPONSE_TIMEPUT                        2.0
#define TIMEOUT_WAS_REACHED                     @"TIMEOUT_WAS_REACHED"

@interface PSWebSocket (internal)
- (NSData *)remoteAddress;
@end

@implementation BSWebTabAdapter {
    
    NSString *_key;
    NSCondition *_actionLock;
    NSDictionary *_lastResponse;
    runningSBApplication *_application;
    dispatch_queue_t _delegateQueue;
}

+ (instancetype)adapterForSocket:(PSWebSocket *)tabSocket {
    
    BSWebTabAdapter *object = [[self alloc] initWithBrowserSocket:tabSocket];
    @try {
        if (object) {
            if ([object suitableForSocket]) {
                object->_standalone = [object obtainStandalone];
                [object sendMessage:@"ready"];
                return object;
            }
        }
    } @catch (NSException *exception) {
        DDLogError(@"Exception occured: %@", exception);
    }
    return nil;
}

- (id)initWithBrowserSocket:(PSWebSocket *)tabSocket {
    
    if (tabSocket == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _delegateQueue = dispatch_queue_create("com.beardie.tab.websocket", DISPATCH_QUEUE_SERIAL);
        _tabSocket = tabSocket;
        _tabSocket.delegate = self;
        _tabSocket.delegateQueue = _delegateQueue;
        _key = [[NSUUID UUID] UUIDString];
        _actionLock = [NSCondition new];
    }
    
    return self;
}

- (BOOL)suitableForSocket{
    return YES;
}

- (id)sendMessage:(id)message {
    id response;
    [_actionLock lock];
    dispatch_async(BSStrategyWebSocketServer.singleton.tabsServer.delegateQueue, ^{
        
        [self.tabSocket send:message];
    });
    if ([_actionLock waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:RESPONSE_TIMEPUT]] == NO) {
        [_actionLock unlock];
        [[NSException exceptionWithName:TIMEOUT_WAS_REACHED reason:nil userInfo:nil] raise];
        _lastResponse = nil;
    }
    if (_lastResponse) {
        response = _lastResponse;
        _lastResponse = nil;
    }
    [_actionLock unlock];
    return response;
}


#pragma mark TabAdapter override

- (runningSBApplication *)application {
    if (_application == nil) {
        @synchronized (self) {
            if (_application == nil) {
                _application = [self obtainApplication];
            }
        }
    }
    return _application;
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
    return [super activateApp];
}

- (BOOL)deactivateApp {
    return [super deactivateApp];
}

- (BOOL)activateTab {

    [super activateTab];
    [self sendMessage:@"activate"];
    return YES;
}

- (BOOL)deactivateTab {
    
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
        DDLogDebug(@"Need activate");

        [self activateApp];
        [self activateTab];
    }
}

- (BOOL)frontmost {
    
    BOOL result = NO;
    NSDictionary *response = [self sendMessage:@"frontmost"];
    result = [response[@"result"] boolValue];
    DDLogDebug(@"Frontmost result for %@: %d, %d", self, [super frontmost], result);
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
    return [[BSTrack alloc] initWithInfo:response];
}

- (BOOL)isPlaying {
    
    NSDictionary *response = [self sendMessage:@"isPlaying"];
    return [response[@"result"] boolValue];
}

- (NSString *)description {
    @try {
        return [NSString stringWithFormat:@"<%@:%p> bundleId: %@, title: %@", [self className], self, self.application.bundleIdentifier, self.title];
    } @catch (NSException *exception) {
        DDLogError(@"Exception occured: %@", exception);
    }
    return [NSString stringWithFormat:@"<%@:%p> bundleId: %@, title: none (TIMEOUT REACHED)", [self className], self, self.application.bundleIdentifier];
}

#pragma mark PSWebSocketDelegate delegates

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    DDLogDebug(@"%s", __FUNCTION__);
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    DDLogDebug(@"%s", __FUNCTION__);
    
    [BSStrategyWebSocketServer.singleton removeTab:self];
}

- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    DDLogDebug(@"\nWebSocket [%p]. Message: %@", webSocket,
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
            ASSIGN_WEAK(self);
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                ASSIGN_STRONG(self);
                @try {
                    //getting current strategy
                    USE_STRONG(self)->_strategy = MediaStrategyRegistry.singleton.strategyCache.cache[strategyName];
                    //sending to client
                    if (USE_STRONG(self)->_strategy.strategyJsBody) {
                        [USE_STRONG(self) sendMessage:USE_STRONG(self)->_strategy.strategyJsBody];
                    }
                    else {
                        DDLogError(@"Bad strategy: %@",strategyName);
                    }
                } @catch (NSException *exception) {
                    DDLogError(@"Exception occured: %@", exception);
                }
            });
            return;
        }
    }
    
    //If we wait response will process it.
    [_actionLock broadcast];
}
- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    DDLogDebug(@"WebSocket [%p]", webSocket);

    [BSStrategyWebSocketServer.singleton removeTab:self];
}

- (void)webSocketDidFlushInput:(PSWebSocket *)webSocket {
    
//    DDLogDebug(@"%s", __FUNCTION__);
}
- (void)webSocketDidFlushOutput:(PSWebSocket *)webSocket {
    
//    DDLogDebug(@"%s", __FUNCTION__);
}
- (BOOL)webSocket:(PSWebSocket *)webSocket evaluateServerTrust:(SecTrustRef)trust {
//    DDLogDebug(@"%s", __FUNCTION__);
    return NO;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

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

- (BOOL)obtainStandalone {
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"standalone"];
        id val = response[@"standalone"];
        if ([val isKindOfClass:[NSNumber class]]) {
            result = [val boolValue];
        }
    }
    @finally{}
    return result;
}

@end

