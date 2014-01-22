//
//  ChromeTabAdapterTest.m
//  BeardedSpice
//
//  Created by Tyler Rhodes on 1/22/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ChromeTabAdapter.h"

@interface ChromeTabAdapterTest : XCTestCase
    @property ChromeApplication *chrome;
    @property ChromeWindow *chromeWindow;
    @property ChromeTab *chromeTab;
    @property NSObject<Tab> *tabAdapter;
@end

@implementation ChromeTabAdapterTest

- (ChromeTab *)openUrl:(NSString *) url inWindow:(ChromeWindow *) window
{
    NSArray *array = [[NSArray alloc] initWithObjects:url, nil];
    [[self chrome] open:array];
    
    return [window activeTab];
}

- (void)setUp
{
    [super setUp];
    [self setChrome: (ChromeApplication *)[SBApplication applicationWithBundleIdentifier:@"com.google.Chrome"]];
    ;
    // TODO
    [self setChromeWindow:[[self chrome] windows][0]];
    [self setChromeTab:[self openUrl:@"file:///Users/trhodes/workspace/bearded-spice/BeardedSpiceTests/Fixtures/test.html" inWindow:[self chromeWindow]]];
    [self setTabAdapter:[ChromeTabAdapter initWithTab:[self chromeTab] andWindow:[self chromeWindow]]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExecuteJavascript
{
    [[self tabAdapter] executeJavascript:@"a='testing';"];
    XCTAssertEqualObjects([[self chromeTab] executeJavascript:@"a;"], @"testing");
}

- (void)testGetTitle
{
    XCTAssertEqualObjects([[self tabAdapter] title], [[self chromeTab] title]);
}

- (void)testGetUrl
{
    XCTAssertEqualObjects([[self tabAdapter] URL], [[self chromeTab] URL]);
}

- (void)shouldHaveSameKeyWithSameTabAndWindow
{
    ChromeTabAdapter *other = [ChromeTabAdapter initWithTab:[self chromeTab] andWindow:[self chromeWindow]];
    XCTAssertEqualObjects([[self tabAdapter] key], [other key]);
}

- (void)testHaveUniqueKeyBetweenTabs
{
    ChromeTabAdapter *other = [ChromeTabAdapter initWithTab:[self openUrl:@"/Users/trhodes/workspace/bearded-spice/BeardedSpiceTests/Fixtures/test.html" inWindow:[self chromeWindow]] andWindow:[self chromeWindow]];
    XCTAssertEqualObjects([[self tabAdapter] key], [other key]);

}
- (void)testHaveUniqueKeyBetweenWindows
{
    
}

@end
