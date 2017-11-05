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
    
}

//+ (instancetype)sharedApplicationForProcessIdentifier:(pid_t)processIdentifier;
+ (instancetype)sharedApplicationForBundleIdentifier:(NSString *)bundleIdentifier;

@property SBApplication *sbApplication;
@property NSString  *bundleIdentifier;
@property (readonly) pid_t processIdentifier;
@property (readonly) BOOL frontmost;
@property BOOL wasActivated;

- (instancetype)initWithApplication:(SBApplication *)application bundleIdentifier:(NSString *)bundleIdentifier;

- (BOOL)activate;
- (BOOL)hide;
- (void)makeKeyFrontmostWindow;


/////////////////////////////////////////////////////////////////////////
#pragma mark Supporting actions in application menubar

- (NSString *)menuBarItemNameForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)pressMenuBarItemForIndexPath:(NSIndexPath *)indexPath;

@end
