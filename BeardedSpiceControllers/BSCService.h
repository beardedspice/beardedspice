//
//  BSCService.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSHeadphoneUnplugListener.h"
#import "Shortcut.h"

@interface BSCService : NSObject < BSHeadphoneUnplugListenerProtocol >

+ (BSCService *)singleton;

- (void)setShortcuts:(NSDictionary <NSString*, MASShortcut *>*)shortcuts;

- (void)setMediaKeysSupportedApps:(NSArray <NSString *>*)bundleIds;

- (void)setPhoneUnplugActionEnabled:(BOOL)enabled;

- (void)setUsingAppleRemoteEnabled:(BOOL)enabled;


- (void)addConnection:(NSXPCConnection *)connection;
- (void)removeConnection:(NSXPCConnection *)connection;

@end
