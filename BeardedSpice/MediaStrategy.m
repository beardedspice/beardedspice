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
    
    notification.title = self.track;
    notification.subtitle = self.album;
    notification.informativeText = self.artist;

    if (self.favorited && [self.favorited boolValue]) {
        
        if (notification.title) {
            notification.title = [NSString stringWithFormat:@"★ %@ ★", notification.title];
        }
        else if (notification.subtitle){
            
            notification.subtitle = [NSString stringWithFormat:@"★ %@ ★", notification.subtitle];
        }
        else if (notification.informativeText){
            
            notification.informativeText = [NSString stringWithFormat:@"★ %@ ★", notification.informativeText];
        }
    }
    
    if (self.image) {
        // workaround for 10.8 support
        if ([notification respondsToSelector:@selector(setContentImage:)]) {
        //
            notification.contentImage = self.image;
        }
    }
    return notification;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    // Do nothing. 
}

@end

@implementation MediaStrategy

-(BOOL) accepts:(TabAdapter *)tab
{
    return YES;
}

-(Track *) trackInfo:(TabAdapter *)tab
{
    return NULL;
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
            if (!url.scheme) {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"http:%@", urlString]];
            }
            _lastImage = [[NSImage alloc] initWithContentsOfURL:url];
        }
        else
            _lastImage = nil;
    }
    
    return _lastImage;
}

@end
