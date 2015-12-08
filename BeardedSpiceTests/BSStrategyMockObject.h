//
//  BSStrategyMockObject.h
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

@import WebKit;

typedef void (^BSVoidBlock)(void);

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
