//
//  BSStrategyWebSocketServer.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategyWebSocketServer.h"
#import "BSTrack.h"

#import "NSString+Utils.h"
#import "MediaStrategyRegistry.h"
#import "BSMediaStrategy.h"
#import "BSPredicateToJS.h"
#import "BSSharedResources.h"
#import "MYAnonymousIdentity.h"
#import "BSBrowserExtensionsController.h"
#import "runningSBApplication.h"
#import "GeneralPreferencesViewController.h"

@import Darwin.POSIX.net;
@import Darwin.POSIX.netinet;

#define SAFARI_EXTENSION_PAIRING_FORMAT                @"https://localhost:%d/pairing.html?bundleId=%@"
#define SAFARI_EXTENSION_PAIRING                       @"pairing.html"



NSString *const BSWebSocketServerStartedNotification = @"BSWebSocketServerStartedNotification";

@implementation BSStrategyWebSocketServer{
    
    NSString *_enabledStrategiesJson;
    NSMutableArray *_observers;
    dispatch_queue_t _workQueue;
    NSOperationQueue *_oQueue;
    NSMutableArray <BSWebTabAdapter *> *_tabs;
    NSMutableArray <PSWebSocket *> *_controlSockets;
    void (^_stopCompletion)(void);
    NSArray *_certs;
}

static BSStrategyWebSocketServer *singletonBSStrategyWebSocketServer;
static NSArray *tabClasses;


/////////////////////////////////////////////////////////////////////
#pragma mark Initialize

+ (BSStrategyWebSocketServer *)singleton{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonBSStrategyWebSocketServer = [BSStrategyWebSocketServer alloc];
        singletonBSStrategyWebSocketServer = [singletonBSStrategyWebSocketServer init];
        tabClasses = @[[BSWebTabSafariAdapter class], [BSWebTabChromeAdapter class], [BSWebTabAdapter class]]; //The order is important
    });
    
    return singletonBSStrategyWebSocketServer;
}

- (id)init{
    
    if (singletonBSStrategyWebSocketServer != self) {
        return nil;
    }
    self = [super init];
    if (self) {
        
        _tabsPort = 0;
        _started = NO;
        _observers = [NSMutableArray new];
        _controlSockets = [NSMutableArray new];
        _workQueue = dispatch_queue_create("com.beardedspice.websocket.server", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

- (void)start {
    
    @synchronized (self) {
        
        if (self.started) {
            return;
        }
        
        if ([self loadCertificate]) {
            [self startTabServer];
        }
        
    }
}

- (void)stopWithComletion:(void (^)(void))completion {
    
    @synchronized (self) {
        
        _stopCompletion = completion;
        _tabs = nil;
        
        for (id item in _observers) {
            [[NSNotificationCenter defaultCenter] removeObserver:item];
        }
        [_observers removeAllObjects];
        
        _oQueue = nil;
        
        [_tabsServer stop];
    }
}

- (NSArray <BSWebTabAdapter *> *)tabs {

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

/////////////////////////////////////////////////////////////////////////
#pragma mark PS Server delegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    
    if (server == _tabsServer) {
        
        BSLog(BSLOG_INFO, @"Websocket Tab server started on port %d.", _tabsPort);
        [self setAcceptersForSafari];
        [BSSharedResources setTabPort:_tabsPort];
    }
    
    if (self.started) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:BSWebSocketServerStartedNotification
             object:self];
        });
    }
}

- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    
    BSLog(BSLOG_ERROR, @"(BSStrategyWebSocketServer) Server failed with error: %@", error);

    [self setStopServer:server];
}

- (void)serverDidStop:(PSWebSocketServer *)server {
    
    BSLog(BSLOG_INFO, @"WebSocket server stoped.");
    
    [self setStopServer:server];
    
    if (_stopCompletion && [self stopped]) {
        ASSIGN_WEAK(_stopCompletion);
        dispatch_async(dispatch_get_main_queue(), ^{
            ASSIGN_STRONG(_stopCompletion);
            if (USE_STRONG(_stopCompletion)) {
                USE_STRONG(_stopCompletion)();
                USE_STRONG(_stopCompletion) = nil;
            }
        });
    }
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {

    BSLog(BSLOG_DEBUG, @"%s. WebSocket [%p]", __FUNCTION__, webSocket);

    static dispatch_queue_t openSocketQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        openSocketQueue = dispatch_queue_create("com.beardedspice.websocket.open", DISPATCH_QUEUE_SERIAL);
    });
    
    //tabs server connection
    if (server == _tabsServer) {
        dispatch_async(openSocketQueue, ^{
            @synchronized (self) {
                id tab;
                for (id item in tabClasses) {
                    tab = [item adapterForSocket:webSocket];
                    if (tab) {
                        break;
                    }
                }
                BSLog(BSLOG_DEBUG, @"Tab Server creates new tab: %@", (tab == nil ? @"NO" : tab));
                if (tab) {
                    [self->_tabs addObject:tab];
                }
                else {
                    BSLog(BSLOG_ERROR, @"Can't create Tab object for socket: %@.\nClose it.", webSocket);
                    [webSocket close];
                }
            }
        });
    }
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    BSLog(BSLOG_DEBUG, @"%s\nWebSocket [%p]. Message: %@", __FUNCTION__, webSocket,
           ([message isKindOfClass:[NSData class]]
            ? [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding]
            : message));
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    BSLog(BSLOG_DEBUG, @"%s", __FUNCTION__);
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    BSLog(BSLOG_DEBUG, @"%s", __FUNCTION__);
}
- (NSHTTPURLResponse *)server:(PSWebSocketServer *)server
   responseOnSimpleGetRequest:(NSURLRequest *)request
                      address:(NSData *)address
                        trust:(SecTrustRef)trust
                 responseBody:(NSData *__autoreleasing *)responseBody {
    
    BSLog(BSLOG_DEBUG, @"%s", __FUNCTION__);

    if ([request.HTTPMethod isEqualToString:@"GET"]) {
    }
    
    return nil;
}

- (void)server:(PSWebSocketServer *)server connectionId:(NSString *)identifier didFailWithError:(NSError *)error {
    if (error.code == errSSLClosedAbort) {
        //May be user removed BeardedSpice certificate from default keychain.
        //restart server
        [self stopWithComletion:^{
            [self start];
        }];
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

- (BOOL)stopped {
    return ! _started;
}

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
        
        NSDictionary *result = [self enabledStrategyDictionary];
        if (result) {
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"accepters": result} options:0 error:NULL];
            _enabledStrategiesJson = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        }
        
        return _enabledStrategiesJson;
    }
}
/**
 Constructs dictionary of the accept functions for enabled strategies.
 
 @return dictionary with {bsJsFunctions:function(){}, 'strategies': {strategyName:function(){}, strategyOtherName:function(){}...} }
 or nil if error occurs.
 */
- (NSDictionary *)enabledStrategyDictionary {
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSMutableDictionary *strategies = [NSMutableDictionary new];
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
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:strategies options:0 error:NULL];
        NSString *stringResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        result[@"strategies"] = stringResult;
        
        result[@"bsJsFunctions"] = [BSPredicateToJS jsFunctions];
        return result;
    }
    
    return nil;
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

- (BOOL)loadCertificate {
    
    NSError *error = NULL;
    SecIdentityRef identity = MYGetOrCreateAnonymousIdentity(BS_NAME, 3600 * 24 * 350, &error);
    if (error || identity == nil) {
        BSLog(BSLOG_ERROR, @"Error occured when creating self signtl certificate: %@", error);
        return NO;
    }
    _certs = @[(__bridge id)identity];
    return YES;
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
            id observer = [[NSNotificationCenter defaultCenter]
                           addObserverForName:BSMediaStrategyRegistryChangedNotification
                           object:nil queue:_oQueue usingBlock:^(NSNotification * _Nonnull note) {
                               
                               [self setAcceptersForSafari];
                               @synchronized (self) {
                                   @autoreleasepool {
                                       self->_enabledStrategiesJson = nil;
                                       // notify only one tab for application
                                       NSMutableSet *bundleIds = [NSMutableSet set];
                                       for (BSWebTabAdapter *item in self->_tabs) {
                                           NSString *bundleId = item.application.bundleIdentifier;
                                           if (bundleId) {
                                               if ([bundleIds containsObject:bundleId]) {
                                                   continue;
                                               }
                                               if ([item notifyThatGlobalSettingsChanged]) {
                                                   [bundleIds addObject:bundleId];
                                               }
                                           }
                                       }
                                   }
                               }
                           }];
            if (observer) {
                [_observers addObject:observer];
            }
            _tabs = [NSMutableArray array];
            
            [_tabsServer start];
            _started = YES;
        }
    }
}

- (void)setStopServer:(PSWebSocketServer *)server {
    @synchronized (self) {
        if (server == _tabsServer) {
            _started = NO;
            _tabsPort = 0;
            [BSSharedResources setTabPort:0];
        }
    }
}

- (NSHTTPURLResponse *)responseForFileUrl:(NSURL *)url mime:(NSString *)mime responseBody:(NSData **)responseBody{
    if (!(url && mime)) {
        return nil;
    }
    NSString *path = [url.path substringFromIndex:1];
    NSURL *pathUrl = [[NSBundle mainBundle] URLForResource:path withExtension:nil];
    if (pathUrl) {
        NSData *body = [NSData dataWithContentsOfURL:pathUrl];
        if (body) {
            
            NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                      statusCode:200
                                                                     HTTPVersion:@"HTTP/1.1"
                                                                    headerFields:@{
                                                                                   @"Content-Type": mime,
                                                                                   @"Content-Length": [NSString stringWithFormat:@"%lu", body.length]
                                                                                   }];
            
            if (responseBody) {
                *responseBody = body;
            }
            return response;
        }
    }
    
    BSLog(BSLOG_ERROR, @"Can't load \"%@\" file from app bundle", url.path);
    return nil;
}

- (void)setAcceptersForSafari {
    [BSSharedResources setAccepters:[self enabledStrategyDictionary] completion:nil];
}

@end
