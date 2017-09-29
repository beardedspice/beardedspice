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
#import "runningSBApplication.h"
#import "netcon-macos.h"

#define RESPONSE_TIMEPUT                    0.1

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
    }
    
    return self;
}

- (NSString *)title {
    NSString *result;
    @try {
        NSDictionary *response = [self sendMessage:@"title"];
        result = response[@"result"];
        if (! [result isKindOfClass:[NSString class]]) {
            result = @"";
        }
    } @catch (NSException *exception) {
        result = @"";
    }
    return result;
}

- (NSString *)key {
    
    return _key;
}

- (void)activateTab {

    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    [super activateTab];
    [self sendMessage:@"activate"];
}

- (BOOL)isActivated {
    
    if (self.application == nil) {
        self.application = [self obtainApplication];
    }
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"isActivated"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    
    return [super isActivated] && result;
}

- (void)toggleTab {
    
    [super toggleTab];
}
- (BOOL)frontmost {
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"frontmost"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    return [super frontmost] && result;
}

- (BOOL)toggle {
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"toggle"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    return result;
}
- (BOOL)pause {
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"pause"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    return result;
}
- (BOOL)next {
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"next"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    return result;
}
- (BOOL)previous {
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"previous"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    return result;
}
- (BOOL)favorite {
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"favorite"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    return result;
}

- (BSTrack *)trackInfo {
    
    BSTrack *result;
    @try {
        NSDictionary *response = [self sendMessage:@"trackInfo"];
        result = [[BSTrack alloc] initWithInfo:response];
    } @catch (NSException *exception) {
        result = nil;
    }
    return result;
}

- (BOOL)isPlaying {
    
    BOOL result = NO;
    @try {
        NSDictionary *response = [self sendMessage:@"isPlaying"];
        result = [response[@"result"] boolValue];
    } @catch (NSException *exception) {
        result = NO;
    }
    return result;
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
    
    BS_LOG(LOG_DEBUG, @"%s", __FUNCTION__);
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

static uint _findpid(const struct sockaddr *addr) {
    
    char *buf = NULL, *p, *end;
    int r;
    uint pid = 0;
    size_t len;
    
    if (addr->sa_family != AF_INET) {
        goto end;
    }
    
    len = 16 * 1024;
    if (NULL == (buf = malloc(len)))
        goto end;
    r = net_pcblist(buf, len, 0);
    if (r == 0)
        goto end;
    else if (r < 0) {
        len = -r;
        free(buf);
        if (NULL == (buf = malloc(len)))
            goto end;
        r = net_pcblist(buf, len, 0);
        if (r <= 0)
            goto end;
    }
    len = r;
    p = buf;
    end = buf + len;
    
    const struct xinpgen *xg = net_pcblist_first(&p, end);
    if (xg == NULL)
        goto end;
    
    const struct xinpcb_n *inp = NULL;
    const struct xsocket_n *so = NULL;
    
    for (;;) {
        const struct xgen_n *xn = net_pcblist_next(&p, end);
        if (xn == NULL)
            break;
        
        switch (xn->xgn_kind) {
                
            case XSO_INPCB:
                inp = (void*)xn;
                break;
                
            case XSO_SOCKET:
                if (inp == NULL)
                    break;
                
                struct sockaddr_in *src = (struct sockaddr_in *)addr;
                so = (void*)xn;
                if (*(uint32_t *)&src->sin_addr == *(uint32_t*)xinp_ip4_local(inp)
                    && src->sin_port == inp->inp_lport) {
                    pid = so->so_uid;
                    goto end;
                }
                
                inp = NULL;
                so = NULL;
                break;
        }
    }
    
end:
    free(buf);
    return pid;
}
