//
//  ChromeTabAdapter.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "Chrome.h"

#define APPID_CHROME            @"com.google.Chrome"
#define APPID_CANARY            @"com.google.Chrome.canary"
#define APPID_YANDEX            @"ru.yandex.desktop.yandex-browser"
#define APPID_CHROMIUM          @"org.chromium.Chromium"

@class runningSBApplication;

@interface ChromeTabAdapter : TabAdapter {
    
    NSInteger _previousTabId;
    ChromeWindow *_previousTopWindow;
    BOOL _wasWindowActivated;
}

+(id) initWithApplication:(runningSBApplication *)application andWindow:(ChromeWindow *)window andTab:(ChromeTab *)tab;

@property ChromeTab *tab;
@property ChromeWindow *window;
@property BOOL applescriptIsolatedVersion;

@end
