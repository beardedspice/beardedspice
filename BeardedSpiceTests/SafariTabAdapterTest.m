//
//  SafariTabAdapterTest.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 1/22/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SafariTabAdapter.h"

@interface SafariTabAdapterTest : XCTestCase
    @property SafariApplication *safari;
    @property SafariWindow *safariWindow;
    @property SafariTab *safariTab;
    @property NSObject<Tab> *tabAdapter;
@end

@implementation SafariTabAdapterTest

- (void)setUp
{
    [super setUp];
    
    [self setSafari: (SafariApplication *)[SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"]];
    ;
    // TODO
    [[self safari] open:[NSURL fileURLWithPath:@"/Users/trhodes/workspace/bearded-spice/BeardedSpiceTests/Fixtures/test.html"]];
    [self setSafariWindow:[[self safari] windows][0]];
    [self setSafariTab:[[self safariWindow] tabs][0]];
    [self setTabAdapter:[SafariTabAdapter initWithApplication:[self safari] andWindow:[self safariWindow] andTab:[self safariTab]]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExecuteJavascript
{
    [[self tabAdapter] executeJavascript:@"globalTestingVar='testing'"];
    XCTAssertEqualObjects([[self safari] doJavaScript:@"globalTestingVar;" in:[self safariTab]], @"testing");
}

- (void)testGetTitle
{
    XCTAssertEqualObjects([[self tabAdapter] title], [[self safariTab] name]);
}

- (void)testGetUrl
{
    XCTAssertEqualObjects([[self tabAdapter] URL], [[self safariTab] URL]);
}

- (void)testHaveSameKeyWithSameTabAndWindow
{
    SafariTabAdapter *other = [SafariTabAdapter initWithApplication:[self safari] andWindow:[self safariWindow] andTab:[self safariTab]];
    XCTAssertEqualObjects([[self tabAdapter] key], [other key]);
}

- (void)testHaveUniqueKeyBetweenTabs
{
//    ChromeTabAdapter *other = [ChromeTabAdapter initWithTab:[self openUrl:@"" inWindow:[self chromeWindow]] andWindow:[self chromeWindow]];
  //  XCTAssertNotEqual([[self tabAdapter] key], [other key]);
    
}
- (void)testHaveUniqueKeyBetweenWindows
{
    
}

@end
