//
//  BSNativeAppTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 26.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"

@class BSTrack;

@interface BSNativeAppTabAdapter : TabAdapter

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

@end
