//
//  MediaHandler.m
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaHandler.h"

@implementation MediaHandler

@synthesize tab;

+(id) initWithTab:(ChromeTab *)tab
{
    MediaHandler *out = [self init];
    out.tab = [tab retain];
    return out;
}
@end
