//
//  SafariTabAdapter.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "Safari.h"

#define APPID_SAFARI            @"com.apple.Safari"

@class runningSBApplication;

@interface SafariTabAdapter : TabAdapter{
    
    SafariTab *_previousTab;
    SafariWindow *_previousTopWindow;
    BOOL _wasWindowActivated;

}

+(id) initWithApplication:(runningSBApplication *)application andWindow:(SafariWindow *)window andTab:(SafariTab *)tab;

@property SafariWindow *window; // we need this for the equality check
@property SafariTab *tab;

@end
