//
//  AmzonMusicTabAdapter.m
//  BeardedSpice
//
//  Created by Karthikeya Udupa on 14/06/2019.
//  Copyright (c) 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "AmazonMusicTabAdapter.h"
#import "runningSBApplication.h"

#define APPNAME_AMAZON_MUSIC           @"Amazon Music"
#define APPID_AMAZON_MUSIC             @"com.amazon.music"


@implementation AmazonMusicTabAdapter

+ (NSString *)displayName{
    
    return APPNAME_AMAZON_MUSIC;
}

+ (NSString *)bundleId{
    
    return APPID_AMAZON_MUSIC;
}

- (NSString *)title {
    
    @autoreleasepool {
        NSString *title = NSLocalizedString(@"Paused", @"Music is paused");
        if([self isPlaying]) {
            title = NSLocalizedString(@"Playing", @"Music is playing");
        }
        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_AMAZON_MUSIC];
    }
}

- (NSString *)URL{
    
    return APPNAME_AMAZON_MUSIC;
}

// We have only one window.
- (NSString *)key{

    return @"A:" APPNAME_AMAZON_MUSIC;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{

    if (otherTab == nil || ![otherTab isKindOfClass:[AmazonMusicTabAdapter class]]) return NO;
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{

    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    [self.application pressMenuBarItemForIndexPath:indexPath];
}

- (void)pause{

    if([self isPlaying]){
        const NSUInteger path[] = {4, 0};
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
        [self.application pressMenuBarItemForIndexPath:indexPath];
    }
}

- (void)next{

    const NSUInteger path[] = {4, 1};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    [self.application pressMenuBarItemForIndexPath:indexPath];
}

- (void)previous{

    const NSUInteger path[] = {4, 2};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    [self.application pressMenuBarItemForIndexPath:indexPath];
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

@end
