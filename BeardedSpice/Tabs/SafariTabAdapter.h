//
//  SafariTabAdapter.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "Tab.h"
#import "Safari.h"

@class runningSBApplication;

@interface SafariTabAdapter : NSObject <Tab>{
    
    BOOL _wasActivated;
    SafariTab *_previousTab;
    SafariWindow *_previousTopWindow;
    BOOL _wasWindowActivated;

}

+(id) initWithApplication:(runningSBApplication *)application andWindow:(SafariWindow *)window andTab:(SafariTab *)tab;

@property runningSBApplication *application;
@property SafariWindow *window; // we need this for the equality check
@property SafariTab *tab;

@end
