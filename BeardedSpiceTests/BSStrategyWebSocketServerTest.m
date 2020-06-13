//
//  BSStrategyWebSocketServerTest.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <XCTest/XCTest.h>
#import "BSStrategyWebSocketServer.h"

@interface BSStrategyWebSocketServerTest : XCTestCase

@end

@implementation BSStrategyWebSocketServerTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStartServer {
    
    BSStrategyWebSocketServer *webSocketServer = [BSStrategyWebSocketServer singleton];
    [webSocketServer start];
    
    XCTAssert(webSocketServer.tabsServer);
    XCTAssert(webSocketServer.tabsPort);
    
    if (webSocketServer.tabsPort) {
        DDLogInfo(@"Server started on %d port", webSocketServer.tabsPort);
    }
    
    [webSocketServer stopWithComletion:nil];
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
