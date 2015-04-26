//
//  ChromeTabAdapter.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "Chrome.h"

@class runningSBApplication;

@interface ChromeTabAdapter : TabAdapter {
    
    NSInteger _previousTabId;
    ChromeWindow *_previousTopWindow;
    BOOL _wasWindowActivated;
}

+(id) initWithApplication:(runningSBApplication *)application andWindow:(ChromeWindow *)window andTab:(ChromeTab *)tab;

@property ChromeTab *tab;
@property ChromeWindow *window;

@end
