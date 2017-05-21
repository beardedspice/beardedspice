//
//  TidalTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 21.05.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "TidalTabAdapter.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "BSTrack.h"
#import "FMDB.h"
#import "sqlite3.h"

#define APPNAME_TIDAL           @"TIDAL"
#define APPID_TIDAL             @"com.tidal.desktop"

#define DB_PATH                 @"TIDAL/Local Storage/https_desktop.tidal.com_0.localstorage"
#define IMAGE_URL_FORMAT        @"https://resources.wimpmusic.com/images/%@/320x320.jpg"

@implementation TidalTabAdapter{
    
    BOOL _needDisplayNotification;

}

static FMDatabaseQueue *dbQueue;

+ (void)initialize {
    
    if (self == [TidalTabAdapter class]) {
        
        [self initDB];
    }
}

+ (NSString *)displayName{
    
    return APPNAME_TIDAL;
}

+ (NSString *)bundleId{
    
    return APPID_TIDAL;
}

- (NSString *)title {

    @autoreleasepool {

        BSTrack *currentTrack = [self trackInfoInternalWithLoadImage:NO];
        
        NSString *title;
        if (currentTrack) {
            
            if (![NSString isNullOrEmpty:currentTrack.track])
            title = currentTrack.track;
            
            if (![NSString isNullOrEmpty:currentTrack.artist]) {
                
                if (title) title = [title stringByAppendingFormat:@" - %@", currentTrack.artist];
                else
                title = currentTrack.artist;
            }
        }
        
        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", @"TidalTabAdapter");
        }
        
        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_TIDAL];
    }
}

- (NSString *)URL{
    
    return APPNAME_TIDAL;
}

// We have only one window.
- (NSString *)key{
    
    return @"A:" APPNAME_TIDAL;
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

- (void)toggle{
    
    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    _needDisplayNotification = YES;
}

- (void)pause{
    
    if ([self isPlaying]) {
        [self toggle];
    }
    
    _needDisplayNotification = YES;
}

- (void)next{
    
    const NSUInteger path[] = {4, 3};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    _needDisplayNotification = NO;
}
- (void)previous{
    
    const NSUInteger path[] = {4, 2};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    [self.application pressMenuBarItemForIndexPath:indexPath];
    
    _needDisplayNotification = NO;
}

- (BOOL)isPlaying{
    
    const NSUInteger path[] = {4, 0};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    
    NSString *menuItemName = [self.application menuBarItemNameForIndexPath:indexPath];
    
    return [menuItemName isEqualToString:
            NSLocalizedStringFromTable(@"Pause", @"TidalTabAdapterMenuItemNames", @"Menu iItem Pause")];
}

- (BSTrack *)trackInfo {
    
    return [self trackInfoInternalWithLoadImage:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark Private Methods

+ (void)initDB {
    
    NSURL *url =  [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString *path = [[url path] stringByAppendingPathComponent:DB_PATH];
    if (path == nil) {
        
        return;
    }
    
    dbQueue = [FMDatabaseQueue databaseQueueWithPath:path flags:SQLITE_OPEN_READONLY];
    //check db
    NSDictionary *userMeta = [self userMeta];
    if (userMeta[@"id"] == nil) {
        
        //bad DB
        dbQueue = nil;
    }
}

+ (NSDictionary *)userMeta {
    
    __block NSDictionary *result;
    [dbQueue inDatabase:^(FMDatabase *db) {
      
        FMResultSet *dbResult = [db executeQuery:@"select * from ItemTable where key like '_TIDAL_%userMeta'"];
        if ([dbResult next]) {
            NSData *data = [dbResult dataNoCopyForColumnIndex:1];
            result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        [dbResult close];
    }];
    
    return result;
}

- (BSTrack *)trackInfoInternalWithLoadImage:(BOOL)loadImage{
    
    NSNumber *userId = [TidalTabAdapter userMeta][@"id"];
    if (! [userId unsignedIntegerValue]) {
        
        return  nil;
    }
    
    __block NSArray *playQueue;
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *dbResult = [db executeQuery:[NSString stringWithFormat:@"select * from ItemTable where key = '_TIDAL_%@playqueue'", userId]];
        if ([dbResult next]) {
            NSData *data = [dbResult dataNoCopyForColumnIndex:1];
            playQueue = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        [dbResult close];
        
    }];
    
    if (playQueue.count) {
        
        NSDictionary *trackMeta = playQueue[0];
        NSMutableDictionary *trackInfo = [NSMutableDictionary
                                          dictionaryWithDictionary:@{
                                                                     kBSTrackNameTrack: trackMeta[@"title"] ?: @"",
                                                                     kBSTrackNameAlbum: trackMeta[@"album"][@"title"] ?: @"",
                                                                     kBSTrackNameArtist: trackMeta[@"artist"][@"name"] ?: @""
                                                                     }];
        
        if (loadImage) {
            NSString *cover = [trackMeta[@"album"][@"cover"] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            if (! [NSString isNullOrEmpty:cover]) {
                
                trackInfo[kBSTrackNameImage] = [NSString stringWithFormat:IMAGE_URL_FORMAT, cover];
            }
        }
        
        return [[BSTrack alloc] initWithInfo:trackInfo];
    }
    
    return nil;
}

@end
