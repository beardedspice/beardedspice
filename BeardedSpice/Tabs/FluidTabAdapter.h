//
//  FluidTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 10.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "Fluid.h"

@interface FluidTabAdapter : TabAdapter{
    
    FluidTab *_previousTab;
    FluidWindow *_previousTopWindow;
    BOOL _wasWindowActivated;
    
}


+(id) initWithApplication:(runningSBApplication *)application window:(FluidWindow *)window browserWindow:(FluidBrowserWindow *)browserWindow tab:(FluidTab *)tab;

@property FluidWindow *window; // we need this for the equality check
@property FluidBrowserWindow *browserWindow; // we need this for the equality check
@property FluidTab *tab;

@end
