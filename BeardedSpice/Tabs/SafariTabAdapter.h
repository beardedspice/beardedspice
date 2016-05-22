//
//  SafariTabAdapter.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "SafariTechnologyPreview.h"

#define APPID_SAFARI            @"com.apple.SafariTechnologyPreview"

@class runningSBApplication;

@interface SafariTabAdapter : TabAdapter{
    
    SafariTechnologyPreviewTab *_previousTab;
    SafariTechnologyPreviewWindow *_previousTopWindow;
    BOOL _wasWindowActivated;

}

+(id) initWithApplication:(runningSBApplication *)application andWindow:(SafariTechnologyPreviewWindow *)window andTab:(SafariTechnologyPreviewTab *)tab;

@property SafariTechnologyPreviewWindow *window; // we need this for the equality check
@property SafariTechnologyPreviewTab *tab;

@end
