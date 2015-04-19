//
//  iTunesTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TabAdapter.h"
#import "iTunes.h"

@class runningSBApplication, Track;

@interface iTunesTabAdapter : TabAdapter{
    
    BOOL _wasActivated;
}

+(instancetype)iTunesTabAdapterWithApplication:(runningSBApplication *)application;

@property runningSBApplication *application;

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

@end
