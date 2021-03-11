//
//  DeezerTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 27.09.19.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

//#import <CoreAudio/CoreAudio.h>
//#import <AudioToolbox/AudioHardwareService.h>

#import "DeezerTabAdapter.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "BSTrack.h"
#import "Deezer-Pause-Names.h"

#define APPNAME           @"DEEZER"
#define APPID             @"com.deezer.deezer-desktop"

@interface DeezerTabAdapter()
@end

@implementation DeezerTabAdapter{
    
}

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
    return DeezerTabAdapter.displayName;
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
    
    if (otherTab == nil || ![otherTab isKindOfClass:[DeezerTabAdapter class]]) return NO;
    
    return YES;
}

- (BOOL)showNotifications {
    
    return NO;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods

- (BOOL)toggle{
    
    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    return YES;
}

- (BOOL)pause{
    if ([self isPlaying]) {
        [self toggle];
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
    
    static dispatch_once_t onceToken;
    static NSSet *pauseNames;
    dispatch_once(&onceToken, ^{
        pauseNames = [NSSet setWithArray:DEEZZER_PAUSE_NAMES];
    });
    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    NSString *menuItemName = [self.application menuBarItemNameForIndexPath:indexPath];
    
    return [pauseNames containsObject:menuItemName];

}

- (BSTrack *)trackInfo {
    
    return nil;
}

//////////////////////////////////////////////////////////////
#pragma mark Private Methods


@end
