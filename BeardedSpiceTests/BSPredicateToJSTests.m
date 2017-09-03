//
//  BSPredicateToJSTests.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 27.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BSPredicateToJS.h"
#import "BSStrategyCache.h"
#import "BSMediaStrategy.h"

@interface BSPredicateToJSTests : XCTestCase

@end

@implementation BSPredicateToJSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    BSStrategyCache *strategyCache = [BSStrategyCache new];
    [strategyCache loadStrategies];
    for (BSMediaStrategy *strategy in strategyCache.allStrategies) {
        
        if (strategy.ty) {
            <#statements#>
        }
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
