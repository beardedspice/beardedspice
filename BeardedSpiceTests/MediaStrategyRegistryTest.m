//
//  MediaStrategyRegistryTest.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 1/22/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MediaStrategyRegistry.h"

@interface MediaStrategyRegistryTest : XCTestCase
    @property MediaStrategyRegistry *mediaStrategyRegistry;
@end

@interface FooBarMediaRegistry : MediaStrategy

@end

@implementation FooBarMediaRegistry

-(BOOL) accepts:(id <Tab>) tab
{
    return [[tab URL] isEqualToString: @"FooBar.com"];
}

@end

@interface FooBarTab : NSObject<Tab>

@end

@implementation FooBarTab

- (NSString *)URL
{
    return @"FooBar.com";
}

- (NSString *) title { return @""; }
- (id) executeJavascript:(NSString *)javascript { return nil; }

@end

@implementation MediaStrategyRegistryTest

- (void)setUp
{
    [super setUp];
    [self setMediaStrategyRegistry:[[MediaStrategyRegistry alloc] init]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddMediaRegistry
{
    MediaStrategy *mediaStrategy = [[FooBarMediaRegistry alloc] init];
    XCTAssertFalse([[[self mediaStrategyRegistry] getMediaStrategies] containsObject:mediaStrategy]);
    [[self mediaStrategyRegistry] addMediaStrategy:mediaStrategy];
    XCTAssertTrue([[[self mediaStrategyRegistry] getMediaStrategies] containsObject:mediaStrategy]);
}

- (void)testRemoveMediaRegistry
{
    MediaStrategy *mediaStrategy = [[FooBarMediaRegistry alloc] init];
    [[self mediaStrategyRegistry] addMediaStrategy:mediaStrategy];
    XCTAssertTrue([[[self mediaStrategyRegistry] getMediaStrategies] containsObject:mediaStrategy]);
    
    [[self mediaStrategyRegistry] removeMediaStrategy:mediaStrategy];
    XCTAssertFalse([[[self mediaStrategyRegistry] getMediaStrategies] containsObject:mediaStrategy]);
}

- (void)testGetForTab
{
    FooBarTab *tab = [[FooBarTab alloc] init];
    XCTAssertEqualObjects([[self mediaStrategyRegistry] getMediaStrategyForTab:tab], NULL);

    MediaStrategy *mediaStrategy = [[FooBarMediaRegistry alloc] init];
    [[self mediaStrategyRegistry] addMediaStrategy:mediaStrategy];
    XCTAssertEqualObjects([[self mediaStrategyRegistry] getMediaStrategyForTab:tab], mediaStrategy);
}

@end
