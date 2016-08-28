//
//  BSStrategyMockObject.h
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

@import WebKit;

typedef void (^BSVoidBlock)(void);

/**
 This object is intended to simulate a browser environment that executes/tests
 the individual strategies. The environment would load a cached copy of each
 website and inject the strategy code to test for response. This also would
 provide a test against future media site changes that break existing strategies.
*/
@interface BSStrategyMockObject : NSObject <WebFrameLoadDelegate>

@property (nonatomic, assign) BOOL finishedLoading;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) WebView *webView;
@property (nonatomic, strong) NSString *strategyName;

+ (NSDictionary *)strategies;

- (instancetype)initWithStrategyName:(NSString *)strategyName;

- (BOOL)start;

- (NSString *)evaluateScript:(NSString *)script;

- (NSURL *)strategyServiceURL;
- (NSURL *)strategyTemplateURL;
- (NSURL *)vcrFileURL;

- (void)recordStrategySite;
- (void)replayStrategySite;

@end
