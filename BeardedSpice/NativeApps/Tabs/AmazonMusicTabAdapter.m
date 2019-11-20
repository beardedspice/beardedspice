//
//  AmzonMusicTabAdapter.m
//  BeardedSpice
//
//  Created by Karthikeya Udupa on 14/06/2019.
//  Copyright (c) 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "AmazonMusicTabAdapter.h"
#import "runningSBApplication.h"

#define APPNAME           @"Amazon Music"
#define APPID             @"com.amazon.music"


@implementation AmazonMusicTabAdapter

+ (NSString *)displayName{
    static NSString *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        name = [super displayName];
    });
    return name ?: APPNAME;
}

+ (NSString *)bundleId{
    
    return APPID;
}

- (NSString *)title {
    
    return AmazonMusicTabAdapter.displayName;
}

- (NSString *)URL{
    
    return APPID;
}

// We have only one window.
- (NSString *)key{

    return @"A:" APPID;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[AmazonMusicTabAdapter class]]) return NO;
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (BOOL)toggle{

    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    return YES;
}

- (BOOL)pause{

    if([self isPlaying]){
        const NSUInteger path[] = {4, 0};
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
        [self.application pressMenuBarItemForIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)next{

    const NSUInteger path[] = {4, 1};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    [self.application pressMenuBarItemForIndexPath:indexPath];
    return YES;
}

- (BOOL)previous{

    const NSUInteger path[] = {4, 2};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    [self.application pressMenuBarItemForIndexPath:indexPath];
    return YES;
}

- (BOOL)isPlaying{

    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    NSString *playPauseMenuItemText = [self.application menuBarItemNameForIndexPath:indexPath];
    if( [playPauseMenuItemText isEqualToString:@"Pause"]) { // Amazon music is not translated and only supports english.
        return YES;
    }
    return NO;
}

- (BOOL)showNotifications {
    
    return NO;
}

@end
