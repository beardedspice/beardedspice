//
//  TidalTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 21.05.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioHardwareService.h>
#import "Tidal-Pause-Names.h"

#import "TidalTabAdapter.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "BSTrack.h"
#import "FMDB.h"
#import "sqlite3.h"

#define APPNAME_TIDAL           @"TIDAL"
#define APPID_TIDAL             @"com.tidal.desktop"

@interface TidalTabAdapter()
@property (class, readonly) FMDatabaseQueue *dbQueue;
@end

@implementation TidalTabAdapter{
    
    BOOL _needDisplayNotification;

}

static FMDatabaseQueue *_dbQueue;

+ (NSString *)displayName{
    static NSString *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        name = [super displayName];
    });
    return name ?: APPNAME_TIDAL;
}

+ (NSString *)bundleId{
    
    return APPID_TIDAL;
}

- (NSString *)title {
    return TidalTabAdapter.displayName;
}

- (NSString *)URL{
    
    return APPID_TIDAL;
}

// We have only one window.
- (NSString *)key{
    
    return @"A:" APPID_TIDAL;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{
    
    if (otherTab == nil || ![otherTab isKindOfClass:[TidalTabAdapter class]]) return NO;
    
    return YES;
}

- (BOOL)showNotifications {
    
    return _needDisplayNotification;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods

- (BOOL)toggle{
    
    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    _needDisplayNotification = YES;
    return YES;
}

- (BOOL)pause{
    
    if ([self isPlaying]) {
        [self toggle];
    }
    
    _needDisplayNotification = YES;
    return YES;
}

- (BOOL)next{
    
    const NSUInteger path[] = {4, 3};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    _needDisplayNotification = NO;
    return YES;
}
- (BOOL)previous{
    
    const NSUInteger path[] = {4, 2};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    _needDisplayNotification = NO;
    return YES;
}

- (BOOL)isPlaying{

    static dispatch_once_t onceToken;
    static NSSet *pauseNames;
    dispatch_once(&onceToken, ^{
        pauseNames = [NSSet setWithArray:TIDAL_PAUSE_NAMES];
    });
    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    NSString *menuItemName = [self.application menuBarItemNameForIndexPath:indexPath];
    
    return [pauseNames containsObject:menuItemName];
}

@end
