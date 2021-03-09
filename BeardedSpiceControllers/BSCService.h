//
//  BSCService.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>
#import "BSHeadphoneStatusListener.h"
#import "Shortcut.h"

@interface BSCService : NSObject < BSHeadphoneStatusListenerProtocol >

+ (BSCService *)singleton;

- (void)setShortcuts:(NSDictionary <NSString*, MASShortcut *>*)shortcuts;

- (void)setMediaKeysSupportedApps:(NSArray <NSString *>*)bundleIds;

- (void)setPhoneUnplugActionEnabled:(BOOL)enabled;

- (BOOL)addConnection:(NSXPCConnection *)connection;
- (void)removeConnection:(NSXPCConnection *)connection;

@end
