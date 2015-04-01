//
//  MediaStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

#define NBSP_STRING                         @"\u00a0"

@implementation Track

@synthesize track;
@synthesize album;
@synthesize artist;

-(NSUserNotification *) asNotification
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    if (self.favorited && [self.favorited boolValue]) {
        
        notification.title = self.track ? [NSString stringWithFormat:@"★ %@ ★", self.track] : nil;
    }
    else
        notification.title = self.track;
    
    notification.subtitle = self.album;
    notification.informativeText = self.artist;
    
    if (self.image) {
        // workaround for 10.8 support
        if ([notification respondsToSelector:@selector(setContentImage:)]) {
        //
            notification.contentImage = self.image;
        }
    }
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

- (NSImage *)imageByUrlString:(NSString *)urlString{
    
    if (!urlString)
        return nil;
    
    if (![urlString isEqualToString:_lastImageUrlString]) {
        
        _lastImageUrlString = urlString;
        NSURL *url = [NSURL URLWithString:urlString];
        if (url) {
            _lastImage = [[NSImage alloc] initWithContentsOfURL:url];
        }
        else
            _lastImage = nil;
    }
    
    return _lastImage;
}

@end
