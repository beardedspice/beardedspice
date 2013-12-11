//
//  SafariTabAdapter.h
//  WebMediaController
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "Tab.h"
#import "Safari.h"

@interface SafariTabAdapter : Tab

+(id) initWithApplication:(SafariApplication *)application andTab:(SafariTab *)tab;

@property (retain) SafariApplication *application;
@property (retain) SafariTab *tab;

@end
