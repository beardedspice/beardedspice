//
//  ChromeTabAdapter.h
//  WebMediaController
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "Tab.h"
#import "Chrome.h"

@interface ChromeTabAdapter : Tab

+(id) initWithTab:(ChromeTab *)tab;

@property ChromeTab *tab;

@end
