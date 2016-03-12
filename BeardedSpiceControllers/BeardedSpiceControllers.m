//
//  BeardedSpiceControllers.m
//  BeardedSpiceControllers
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "BeardedSpiceControllers.h"
#import "BSCService.h"

@implementation BeardedSpiceControllers

- (void)setShortcuts:(NSDictionary <NSString*, MASShortcut *> *)shortcuts{
    NSLog(@"setShortcuts");
    
    [[BSCService singleton] setShortcuts:shortcuts];
}

- (void)setMediaKeysSupportedApps:(NSArray <NSString *>*)bundleIds{
    NSLog(@"setMediaKeysSupportedApps");
    
    [[BSCService singleton] setMediaKeysSupportedApps:bundleIds];
}

- (void)setPhoneUnplugActionEnabled:(BOOL)enabled{
    NSLog(@"setPhoneUnplugActionEnabled");
    
    [[BSCService singleton] setPhoneUnplugActionEnabled:enabled];
}

- (void)setUsingAppleRemoteEnabled:(BOOL)enabled{
    NSLog(@"setUsingAppleRemoteEnabled");
    
    [[BSCService singleton] setUsingAppleRemoteEnabled:enabled];
}

- (void)prepareForClosingConnectionWithCompletion:(void (^)(void))completion{

    [[BSCService singleton] removeConnection:_connection];
    
    completion();
}

@end
