//
//  runningApplication.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 07.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

@interface runningSBApplication : NSObject{
    
    pid_t _processIdentifier;
}

@property SBApplication *sbApplication;
@property NSString  *bundleIdentifier;
@property (readonly) pid_t processIdentifier;
@property (readonly) BOOL frontmost;

- (instancetype)initWithApplication:(SBApplication *)application bundleIdentifier:(NSString *)bundleIdentifier;

- (void)activate;
- (void)hide;
- (void)makeKeyFrontmostWindow;


@end
