//
//  BeardedSpiceControllersProtocol.h
//  BeardedSpiceControllers
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>

@class MASShortcut;

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol BeardedSpiceControllersProtocol

- (void)setShortcuts:(NSDictionary <NSString*, MASShortcut *> *)shortcuts;

- (void)setMediaKeysSupportedApps:(NSArray <NSString *>*)bundleIds;

- (void)setPhoneUnplugActionEnabled:(BOOL)enabled;

- (void)setUsingAppleRemoteEnabled:(BOOL)enabled;

- (void)prepareForClosingConnectionWithCompletion:(void (^)(void))completion;

@end

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:BS_CONTROLLER_BUNDLE_ID];
     _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(StringModifing)];
     [_connectionToService resume];

Once you have a connection to the service, you can use it like this:

     [[_connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
         // We have received a response. Update our text field, but do it on the main thread.
         DDLogDebug(@"Result string was: %@", aString);
     }];

 And, when you are finished with the service, clean up the connection like this:

     [_connectionToService invalidate];
*/
