//
//  NativeAppTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 26.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"

@class Track;

@interface NativeAppTabAdapter : TabAdapter

+(id)tabAdapterWithApplication:(runningSBApplication *)application;

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

/**
 Returns name of that native app.
 */
+ (NSString *)displayName; // Required override in subclass.

/**
 Returns bundle identifier of that native app.
 */
+ (NSString *)bundleId; // Required override in subclass.

- (void)toggle;
- (void)pause;
- (void)next;
- (void)previous;
- (void)favorite;

- (Track *)trackInfo;
- (BOOL)isPlaying;

/**
    Indicates when BeardedSpice may display notifications.
 */
- (BOOL)showNotifications;

@end
