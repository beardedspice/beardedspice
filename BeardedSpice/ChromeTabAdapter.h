//
//  ChromeTabAdapter.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "Tab.h"
#import "Chrome.h"

@interface ChromeTabAdapter : NSObject <Tab>

+(id) initWithApplication:(ChromeApplication *)application andWindow:(ChromeWindow *)window andTab:(ChromeTab *)tab;

@property ChromeApplication *application;
@property ChromeTab *tab;
@property ChromeWindow *window;

@end
