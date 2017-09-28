//
//  BSStrategyWebSocketServer.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyWebSocketServer.h"
#import "BSWebTabAdapter.h"
#import "BSTrack.h"

#import "NSString+Utils.h"
#import "MediaStrategyRegistry.h"
#import "BSMediaStrategy.h"
#import "BSPredicateToJS.h"
#import "BSSharedDefaults.h"
#import "BSBrowserExtensionMessages.h"

@import Darwin.POSIX.net;
@import Darwin.POSIX.netinet;

#define SAFARI_EXTENSION_DEFAULTS_KEY       @"ExtensionSettings-com.beardedspice.BeardedSpice.SafariExtension-0000000000"

@implementation BSStrategyWebSocketServer{
    
    NSString *_enabledStrategiesJson;
    id _observer;
    dispatch_queue_t _workQueue;
    NSOperationQueue *_oQueue;
    NSMutableArray <BSWebTabAdapter *> *_tabs;
    void (^_stopCompletion)(void);
    NSArray *_certs;
    BOOL _controlStarted, _tabsStarted;
}

static BSStrategyWebSocketServer *singletonBSStrategyWebSocketServer;

/////////////////////////////////////////////////////////////////////
#pragma mark Initialize

+ (BSStrategyWebSocketServer *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonBSStrategyWebSocketServer = [BSStrategyWebSocketServer alloc];
        singletonBSStrategyWebSocketServer = [singletonBSStrategyWebSocketServer init];
    });
    
    return singletonBSStrategyWebSocketServer;
}

- (id)init{
    
    if (singletonBSStrategyWebSocketServer != self) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        _tabsPort = _controlPort = 0;
        _controlStarted = _tabsStarted = NO;
        _workQueue = dispatch_queue_create("com.beardedspice.websocket.server", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

- (BOOL)started {
    return _controlStarted && _tabsStarted;
}

- (void)start {
    
    @synchronized (self) {
        
        if (self.started) {
            return;
        }
        
        [self loadCertificate];
        
        _controlPort = [self getFreeListeningPortFrom:8008 poolCount:20];
        if (_controlPort) {
            _controlServer = [PSWebSocketServer serverWithHost:@"127.0.0.1" port:_controlPort SSLCertificates:_certs];
            _controlServer.delegateQueue = _workQueue;
            _controlServer.delegate = self;
            [_controlServer start];
            
            _controlStarted = YES;
        }
    }
}

- (void)stopWithComletion:(void (^)(void))completion {
    
    @synchronized (self) {
        
        _stopCompletion = completion;
        _tabs = nil;
        
        if (_observer) {
            [[NSNotificationCenter defaultCenter] removeObserver:_observer];
            _observer = nil;
        }
        _oQueue = nil;
        
        [_tabsServer stop];
        [_controlServer stop];
    }
}

- (NSArray *)tabs {
    
    @synchronized (self) {
        return [_tabs copy];
    }
}
- (void)removeTab:(BSWebTabAdapter *)tab {
    
    @synchronized (self) {
        if (tab) {
            [_tabs removeObject:tab];
        }
    }
}

- (BOOL)frontmost:(BSWebTabAdapter *)tab {
    
    return NO;
}

- (BOOL)isActivated:(BSWebTabAdapter *)tab {
    
    return NO;
}

- (void)toggleTab:(BSWebTabAdapter *)tab {
    
}
- (void)activateTab:(BSWebTabAdapter *)tab {
    
}
- (NSString *)title:(BSWebTabAdapter *)tab {
    
    return @"No title";
}

- (void)toggle:(BSWebTabAdapter *)tab {
    
}
- (void)pause:(BSWebTabAdapter *)tab {
    
}
- (void)next:(BSWebTabAdapter *)tab {
    
}
- (void)previous:(BSWebTabAdapter *)tab {
    
}
- (void)favorite:(BSWebTabAdapter *)tab {
    
}

- (BSTrack *)trackInfo:(BSWebTabAdapter *)tab {
    
    return nil;
}
- (BOOL)isPlaying:(BSWebTabAdapter *)tab {
    
    return NO;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark PS Server delegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    
    if (server == _controlServer) {
        
        NSLog(@"Websocket Control server started on port %d.", _controlPort);
        [self startTabServer];
    }
    if (server == _tabsServer) {
        
        NSLog(@"Websocket Tab server started on port %d.", _tabsPort);
    }

    //TODO: change preferences for browser extensions, anonce new port for connection to this server
}
- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    
    NSLog(@"(BSStrategyWebSocketServer) Server failed with error: %@", error);

    [self setStopServer:server];
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    
    NSLog(@"WebSocket server stoped.");
    
    [self setStopServer:server];
    
    if (_stopCompletion && ! self.started) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _stopCompletion();
            _stopCompletion = nil;
        });
    }
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {

    NSLog(@"%s", __FUNCTION__);
    
    //tabs server connection
    if (server == _tabsServer) {
        @synchronized (self) {
            
            BSWebTabAdapter *tab = [[BSWebTabAdapter alloc] initWithBrowserSocket:webSocket];
            [_tabs addObject:tab];
        }
    }
    
    //TODO: send list of the working stranegy
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSLog(@"%s", __FUNCTION__);
    
    //control request
    if (server == _controlServer) {
        NSData *messageData = [message isKindOfClass:[NSString class]] ?
        [message dataUsingEncoding:NSUTF8StringEncoding]
        : message;
        
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:messageData options:0 error:NULL];
        if (response) {
            NSString *request = response[@"request"];
            if ([request isEqualToString:@"accepters"]) {
                [webSocket send:[self enabledStrategy]];
            }
            else if ([request isEqualToString:@"port"]) {
                if (_tabsStarted) {
                    [webSocket send:[NSString stringWithFormat:@"{\"port\":%d}", _tabsPort]];
                }
                else {
                    [webSocket send:@"{\"result\":false}"];
                }
            }
        }
    }
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    NSLog(@"%s", __FUNCTION__);
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    NSLog(@"%s", __FUNCTION__);
}


/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

- (uint16_t)getFreeListeningPortFrom:(uint16_t)port poolCount:(uint16_t)poolCount {
    
    if (!poolCount) {
        poolCount = 1;
    }
    // create IPv4 socket
    int fd4 = socket(AF_INET, SOCK_STREAM, 0);
    
    // allow for reuse of local address
    static const int yes = 1;
    int err = setsockopt(fd4, SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));
    
    // a structure for the socket address
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_family = AF_INET;
    sin.sin_len = sizeof(sin);
    
    for (uint16_t i = 0; i < poolCount; i++) {
        sin.sin_port = htons(port);  // if 0, then asks kernel for arbitrary port number
        err = bind(fd4, (const struct sockaddr *)&sin, sin.sin_len);
        if (err == 0)
            break;
        if (errno != EADDRINUSE) {
            return 0;
        }
    }
    
    socklen_t addrLen = sizeof(sin);
    err = getsockname(fd4, (struct sockaddr *)&sin, &addrLen);
    close(fd4);
    
    uint16_t outPort = ntohs(sin.sin_port);
    
    return outPort;
}

/**
 Constructs JSON with dictionary of the accept functions for enabled strategies.

 @return JSON in form {bsJsFunctions:function(){}, 'strategies': {strategyName:function(){}, strategyOtherName:function(){}...} }
         or nil if error occurs.
 */
- (NSString *)enabledStrategy {
    
    @synchronized (self) {
        
        if (_enabledStrategiesJson) {
            return _enabledStrategiesJson;
        }
        
        NSMutableDictionary *result = [NSMutableDictionary new];
        NSMutableDictionary *strategies = [NSMutableDictionary new];
        result[@"strategies"] = strategies;
        for (BSMediaStrategy *strategy in MediaStrategyRegistry.singleton.availableStrategies) {
            
            NSDictionary *params = strategy.acceptParams;
            if ([params[kBSMediaStrategyAcceptMethod] isEqualToString:kBSMediaStrategyAcceptPredicateOnTab]) {
                
                NSPredicate *predicate = params[kBSMediaStrategyKeyAccept];
                
                NSString *converted = [NSString stringWithFormat:@"function bsAccepter(){ return ( %@ );}", [BSPredicateToJS jsFromPredicate:predicate]];
                if (! [NSString isNullOrEmpty:converted]) {
                    
                    strategies[strategy.fileName] = converted;
                }
            }
            else if ([params[kBSMediaStrategyAcceptMethod] isEqualToString:kBSMediaStrategyAcceptScript]) {
                
                NSString *script = params[kBSMediaStrategyKeyAccept];
                if (! [NSString isNullOrEmpty:script]) {
                    
                    strategies[strategy.fileName] = [NSString stringWithFormat:@"function bsAccepter(){ return ( %@ );}",script];
                }
            }
        }
        
        if (strategies.count) {
            
            result[@"bsJsFunctions"] = [BSPredicateToJS jsFunctions];
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"accepters": result} options:0 error:NULL];
            _enabledStrategiesJson = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        }
        
        return _enabledStrategiesJson;
    }
}

//- (void)sendStrategyAccepters {
//    
//    dispatch_async(self.server.delegateQueue, ^{
//        
//        NSData *message = [self enabledStrategy];
//        for (PSWebSocket *webSocket in _webSockets) {
//            [webSocket send:message];
//        }
//    });
//}

//- (void)removeTabWithSocket:(PSWebSocket *)webSocket {
//
//    __block BSWebTabAdapter *tab = nil;
//    [_tabs enumerateObjectsUsingBlock:^(BSWebTabAdapter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        if ([obj.tabSocket isEqual:webSocket]) {
//            tab = obj;
//            *stop = YES;
//        }
//    }];
//    if (tab) {
//        [_tabs removeObject:tab];
//    }
//}

- (void)loadCertificate {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURL *certUrl = [[NSBundle mainBundle] URLForResource:@"certificate" withExtension:@"p12"];
        if (certUrl) {
            
            NSData *certData = [NSData dataWithContentsOfURL:certUrl];
            if (certData) {
                NSString *dfhfq10Fl5 = @"NbgfGfhjkm";
                NSDictionary *options = @{ (id)kSecImportExportPassphrase : dfhfq10Fl5 };
                CFArrayRef rawItems = NULL;
                OSStatus status = SecPKCS12Import((__bridge CFDataRef)certData,
                                                  (__bridge CFDictionaryRef)options,
                                                  &rawItems);
                
                NSArray* items = (NSArray*)CFBridgingRelease(rawItems);
                NSDictionary* firstItem = nil;
                if ((status == errSecSuccess) && ([items count]>0)) {
                    firstItem = items[0];
                    SecIdentityRef identity =
                    (SecIdentityRef)CFBridgingRetain(firstItem[(id)kSecImportItemIdentity]);
                    if (identity) {
                        _certs = @[(__bridge_transfer id)identity];
                    }
                }
            }
        }
    });
}
- (void)startTabServer {
    
    @synchronized (self) {
        
        _tabsPort = [self getFreeListeningPortFrom:0 poolCount:0];
        if (_tabsPort) {
            _tabsServer = [PSWebSocketServer serverWithHost:@"127.0.0.1" port:_tabsPort SSLCertificates:_certs];
            _tabsServer.delegateQueue = _workQueue;
            _tabsServer.delegate = self;
            
            _oQueue = [NSOperationQueue new];
            _oQueue.underlyingQueue = _tabsServer.delegateQueue;
            _observer = [[NSNotificationCenter defaultCenter] addObserverForName:BSMediaStrategyRegistryChangedNotification
                                                                          object:nil queue:_oQueue usingBlock:^(NSNotification * _Nonnull note) {
                                                                              
                                                                              @synchronized (self) {
                                                                                  _enabledStrategiesJson = nil;
                                                                              }
                                                                              
                                                                              //TODO: add notification of all clients that strategies was changed
                                                                          }];
            _tabs = [NSMutableArray array];
            
            [_tabsServer start];
            _tabsStarted = YES;
        }
    }
}

- (void)setStopServer:(PSWebSocketServer *)server {
    @synchronized (self) {
        if (server == _controlServer) {
            _controlStarted = NO;
        }
        else if (server == _tabsServer) {
            _tabsStarted = NO;
        }
    }
}

@end
