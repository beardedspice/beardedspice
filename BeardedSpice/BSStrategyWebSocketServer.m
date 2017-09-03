//
//  BSStrategyWebSocketServer.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "BSStrategyWebSocketServer.h"
#import "BSWebTabAdapter.h"
#import "BSTrack.h"

@import Darwin.POSIX.net;
@import Darwin.POSIX.netinet;

@implementation BSStrategyWebSocketServer{
    
    
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
        
        _port = 0;
    }
    
    return self;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

- (void)start {
    
    _port = [self getFreeListeningPort];
    
    _server = [PSWebSocketServer serverWithHost:@"127.0.0.1" port:_port];
    _server.delegate = self;
    
    [_server start];
}

- (void)stop {
    
    [_server stop];
}

- (BOOL)frontmost:(BSWebTabAdapter *)tab {
    
}

- (BOOL)isActivated:(BSWebTabAdapter *)tab {
    
}
- (void)toggleTab:(BSWebTabAdapter *)tab {
    
}
- (void)activateTab:(BSWebTabAdapter *)tab {
    
}
- (NSString *)title:(BSWebTabAdapter *)tab {
    
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
    
}
- (BOOL)isPlaying:(BSWebTabAdapter *)tab {
    
}

/////////////////////////////////////////////////////////////////////////
#pragma mark PS Server delegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    //TODO: change preferences for browser extensions, anonce new port for connection to this server
}
- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    
    NSLog(@"(BSStrategyWebSocketServer) Server failed with error: %@", error);
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    
}

- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {

    //TODO: send list of the working stranegy
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}


/////////////////////////////////////////////////////////////////////////
#pragma mark Private methods

- (uint16_t)getFreeListeningPort {
    
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
    sin.sin_port = htons(0);  // asks kernel for arbitrary port number
    
    err = bind(fd4, (const struct sockaddr *)&sin, sin.sin_len);
    
    socklen_t addrLen = sizeof(sin);
    err = getsockname(fd4, (struct sockaddr *)&sin, &addrLen);
    close(fd4);
    
    uint16_t port = sin.sin_port;
    
    return port;
}

@end
