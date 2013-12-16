//
//  ChromeTabAdapter.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/10/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ChromeTabAdapter.h"

@implementation ChromeTabAdapter

+ (id)initWithTab:(ChromeTab *)tab andWindow:(ChromeWindow *) window
{
    ChromeTabAdapter *out = [[ChromeTabAdapter alloc] init];
    [out setTab:tab];
    [out setWindow:window];
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

-(BOOL) isEqual:(__autoreleasing id)object
{
    if (object == nil || ![object isKindOfClass:[ChromeTabAdapter class]]) return NO;
    
    ChromeTabAdapter *other = (ChromeTabAdapter *)object;
    return self.tab.id == other.tab.id;
}

-(NSString *) key
{
    return [NSString stringWithFormat:@"C:%ld:%ld", [self.window index], [self.tab id]];
}

@end
