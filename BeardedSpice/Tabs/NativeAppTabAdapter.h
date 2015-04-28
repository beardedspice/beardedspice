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

- (void)toggle;
- (void)pause;
- (void)next;
- (void)previous;
- (void)favorite;

- (Track *)trackInfo;
- (BOOL)isPlaying;

/**
    Indicates when app may display notifications.
 */
- (BOOL)showNotifications;

@end
