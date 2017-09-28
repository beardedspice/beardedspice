//
//  SafariExtensionHandler.m
//  SafariExtension
//
//  Created by Roman Sokolov on 14.09.17.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSSafariExtensionHandler.h"
#import "BSSharedDefaults.h"
#import "BSBrowserExtensionMessages.h"

#define WEBSOCKET_SERVER_REQUEST_TIMEOUT                    2 // in seconds

@implementation BSSafariExtensionHandler {
    
    PSWebSocket *_webSocketClient;
}

- (id)init {

    self = [super init];
    if (self) {
        NSLog(@"INIT %p", self);
    }
    
    return self;
}

- (void)dealloc {
    
    NSLog(@"DEALLOC %p", self);
}

- (void)messageReceivedWithName:(NSString *)messageName fromPage:(SFSafariPage *)page userInfo:(NSDictionary *)userInfo {
    
    [page getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties *properties) {
        
        NSLog(@"Message from script: %@", messageName);
        NSLog(@"Properties: %d", properties.active);
        NSLog(@"%@", userInfo);

        if ([messageName isEqualToString:@"accepters"]) {
            NSData *acceptersData = [[BSSharedDefaults defaults] objectForKey:BSWebSocketServerStrategyAcceptors];
            if (acceptersData) {
                NSDictionary *accepters = [NSJSONSerialization JSONObjectWithData:acceptersData options:0 error:NULL];
                if (accepters) {
                    [page dispatchMessageToScriptWithName:@"accepters" userInfo:accepters];
                }
            }
        }
        else if ([messageName isEqualToString:@"port"]) {
            NSNumber *portVal = [[BSSharedDefaults defaults] objectForKey:BSWebSocketServerPort];
            if ([portVal integerValue] > 0) {
                NSDictionary *port = @{@"result": portVal};
                [page dispatchMessageToScriptWithName:@"port" userInfo:port];
            }
        }
        else if ([messageName isEqualToString:@"frontmost"]) {
            [SFSafariApplication getActiveWindowWithCompletionHandler:^(SFSafariWindow * _Nullable activeWindow) {
                NSLog(@"Active window obtained: %@", activeWindow);
                if (activeWindow) {
                    [activeWindow getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
                        NSLog(@"Active tab obtained: %@", activeTab);
                        [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
                            NSLog(@"Active page obtained: %@", activePage);
                            [page dispatchMessageToScriptWithName:@"frontmost"
                                                         userInfo:@{@"result": @([activePage isEqual:page])}];
                        }];
                    }];
                }
            }];
        }
    }];
}

- (void)messageReceivedFromContainingAppWithName:(NSString *)messageName userInfo:(nullable NSDictionary<NSString *, id> *)userInfo {
    
    NSLog(@"Message received from containing app.");
//    if ([messageName isEqualToString:BSExtMessageServerStarted]) {
//
//        [self startWebSocketOnPort:[userInfo[BSWebSocketServerPort] integerValue]];
//    }
}

- (void)beginRequestWithExtensionContext:(NSExtensionContext *)context {
    
    NSLog(@"beginRequestWithExtensionContext: %@", context);
}

@end
