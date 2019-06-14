//
//  AmzonMusicTabAdapter.m
//  BeardedSpice
//
//  Created by Karthikeya Udupa on 14/06/2019.
//  Copyright © 2019 BeardedSpice. All rights reserved.
//

#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioHardwareService.h>

#import "AmazonMusicTabAdapter.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "runningSBApplication.h"
#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

#define APPNAME_AMAZON_MUSIC           @"AMAZON MUSIC"
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
        NSString *title = @"Paused";
        if([self isPlaying]) {
           title = @"Playing";
        }
        return [NSString stringWithFormat:@"%@ (Amazon Music)", title];
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

- (BSTrack *)trackInfo{

    // TODO: Find the current logic.
    return nil;
}

- (BOOL)isPlaying{

    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    NSString *playPauseMenuItemText = [self.application menuBarItemNameForIndexPath:indexPath];
    if( [playPauseMenuItemText isEqualToString:@"Pause"]) { // TODO: Add translation support.
        return YES;
    }
    return NO;
}

@end
