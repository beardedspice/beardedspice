//
//  MediaStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@implementation Track

@synthesize track;
@synthesize album;
@synthesize artist;

-(NSUserNotification *) asNotification
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = self.track;
    notification.subtitle = self.album;
    notification.informativeText = self.artist;
    return notification;
}

@end

@implementation MediaStrategy

-(BOOL) accepts:(id <Tab>)tab
{
    return YES;
}
-(NSString *) toggle
{
    return @"";
}
-(NSString *) previous
{
    return @"";
}
-(NSString *) next
{
    return @"";
}
-(NSString *) pause
{
    return @"";
}
-(NSString *) displayName
{
    return @"";
}
-(Track *) trackInfo:(id<Tab>)tab
{
    return NULL;
}

-(NSString *) favorite
{
    NSLog(@"Favoriting not yet implemented for %s", [[self displayName] UTF8String]);
    return @"";
}

@end
