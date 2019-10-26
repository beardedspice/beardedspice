//
//  BSPredicateToJSTests.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 27.08.17.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
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

- (void)testComparisionConvertion {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K < %@", @"val", @(1)];
    NSString *converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsParameters.val < 1"]);
    
    predicate = [NSPredicate predicateWithFormat:@"self.val <= %@", @(1.1)];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsParameters.val <= 1.1000000000000001"]);
    
    predicate = [NSPredicate predicateWithFormat:@"val > 1"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsParameters.val > 1"]);

    predicate = [NSPredicate predicateWithFormat:@"SELF >= 1"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsParameters >= 1"]);

    predicate = [NSPredicate predicateWithFormat:@"obj.title == 'value'"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsParameters.obj.title == \"value\""]);
    
    predicate = [NSPredicate predicateWithFormat:@"obj.title != %@", @"value"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsParameters.obj.title != \"value\""]);
    
    predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @".+\\sopa.*"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([predicate evaluateWithObject:@"zsdasdfas asdfasdfasdg opa tipa"]);
    XCTAssertTrue([converted isEqualToString:@"bsMatchesPredicate(bsParameters, \".+\\\\sopa.*\", )"]);
    
    predicate = [NSPredicate predicateWithFormat:@"obj.title LIKE[c] %@", @"?opa*"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsLikePredicate(bsParameters.obj.title, \"?opa*\", \"i\")"]);

    predicate = [NSPredicate predicateWithFormat:@"obj.title BEGINSWITH[cd] %@", @"opa"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsBeginsWithPredicate(bsParameters.obj.title, \"opa\", \"i\")"]);
    
    predicate = [NSPredicate predicateWithFormat:@"obj.title ENDSWITH[cd] %@", @"opa"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsEndsWithPredicate(bsParameters.obj.title, \"opa\", \"i\")"]);
    
    predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS 'tipa'", @"opa"];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsContainsPredicate(bsParameters.opa, \"tipa\", )"]);

    predicate = [NSPredicate predicateWithFormat:@"obj.title IN %@", @[@"opa", @"tipa"]];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsInPredicate(bsParameters.obj.title, [\"opa\",\"tipa\"], )"]);

    predicate = [NSPredicate predicateWithFormat:@"val BETWEEN %@", @[@1 , @10]];
    converted = [BSPredicateToJS jsFromPredicate:predicate];
    
    XCTAssertTrue([converted isEqualToString:@"bsBetweenPredicate(bsParameters.val, [1,10], )"]);
}

- (void)testCompoundConvertion {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((title CONTAINS[c] %@) AND opa == TRUE AND tipa == FALSE) OR (title == 'tipa' AND (opa > 1 OR %K < 1))", @"opa", @"tipa"];
    NSString *converted = [BSPredicateToJS jsFromPredicate:predicate];

    XCTAssertTrue([converted isEqualToString:@"( ( bsContainsPredicate(bsParameters.title, \"opa\", \"i\") ) && ( bsParameters.opa == true ) && ( bsParameters.tipa == false ) ) || ( ( bsParameters.title == \"tipa\" ) && ( ( bsParameters.opa > 1 ) || ( bsParameters.tipa < 1 ) ) )"]);
}

- (void)testPrintJSFunctions {
    
    NSLog(@"JS Functions:\n%@", [BSPredicateToJS jsFunctions]);
}

- (void)testPrintJSConditions {
    
    BSStrategyCache *strategyCache = [BSStrategyCache new];
    [strategyCache loadStrategies];
    for (BSMediaStrategy *strategy in strategyCache.allStrategies) {
        
        NSDictionary *params = strategy.acceptParams;
        if ([params[kBSMediaStrategyAcceptMethod] isEqualToString:kBSMediaStrategyAcceptPredicateOnTab]) {
            
            NSPredicate *predicate = params[kBSMediaStrategyKeyAccept];
            
            NSString *converted = [BSPredicateToJS jsFromPredicate:predicate];
            
            NSLog(@"Strategy: %@\n%@\n", strategy.displayName, converted);
        }
    }
}

@end
