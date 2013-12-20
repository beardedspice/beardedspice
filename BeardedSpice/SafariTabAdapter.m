//
//  SafariTabAdapter.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "SafariTabAdapter.h"

@implementation SafariTabAdapter

+ (id)initWithApplication:(SafariApplication *)application andWindow:(SafariWindow *)window andTab:(SafariTab *)tab
{
    SafariTabAdapter *out = [[SafariTabAdapter alloc] init];
    [out setTab:[tab get]];
    [out setWindow:[window get]];
    [out setApplication:application];
    return out;
}

-(id) executeJavascript:(NSString *) javascript
{
    return [self.application doJavaScript:javascript in:self.tab];
}

-(NSString *) title
{
    return [self.tab name];
}

-(NSString *) URL
{
    return [self.tab URL];
}

-(BOOL) isEqual:(__autoreleasing id)object
{
    if (object == nil || ![object isKindOfClass:[SafariTabAdapter class]]) return NO;
    
    SafariTabAdapter *other = (SafariTabAdapter *)object;

    return (self.window.id == other.window.id) && (self.tab.index == other.tab.index);
}

-(NSString *) key
{
    return [NSString stringWithFormat:@"S:%ld:%ld", [self.window index], [self.tab index]];
}

@end
