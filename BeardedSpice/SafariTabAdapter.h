//
//  SafariTabAdapter.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "Tab.h"
#import "Safari.h"

@interface SafariTabAdapter : NSObject <Tab>

+(id) initWithApplication:(SafariApplication *)application andWindow:(SafariWindow *)window andTab:(SafariTab *)tab;

@property SafariApplication *application; // we need this for executing js.
@property SafariWindow *window; // we need this for the equality check
@property SafariTab *tab;

@end
