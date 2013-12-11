//
//  ChromeTabAdapter.m
//  WebMediaController
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ChromeTabAdapter.h"

@implementation ChromeTabAdapter

+ (id)initWithTab:(ChromeTab *)tab
{
    ChromeTabAdapter *out = [[ChromeTabAdapter alloc] init];
    [out setTab:tab];
    return out;
}


-(id) executeJavascript:(NSString *) javascript
{
    return [self.tab executeJavascript:javascript];
}

-(NSString *) title
{
    return [self.tab title];
}

-(NSString *) URL
{
    return [self.tab URL];
}

@end
