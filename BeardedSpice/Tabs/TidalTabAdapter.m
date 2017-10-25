//
//  TidalTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 21.05.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioHardwareService.h>

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

#define VOLUME_STEP             0.055555556

typedef enum {
    
    TAResultSystem = 0,
    TAResultSystemCustom,
    TAResultTidal,
    TAResultUnavailable
} TAResult;

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
#pragma mark BSVolumeControlProtocol Methods

- (BSVolumeControlResult)volumeDown {

    const NSUInteger path[] = {4, 9};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    NSString *audioDeviceUID;

    BSVolumeControlResult result = BSVolumeControlNotSupported;
    
    switch ([self testAudioConfiguration:&audioDeviceUID]) {
        case TAResultTidal:
            
            [self.application pressMenuBarItemForIndexPath:indexPath];
            result = BSVolumeControlDown;
            break;
            
        case TAResultUnavailable:
            
            result = BSVolumeControlUnavailable;
            break;
            
        case TAResultSystemCustom:
            
            result = [self setVolumeWithSign:-1 device:[self audioDeviceWithUUID:audioDeviceUID]];
            break;
            
        default:
            break;
    }
    
    return result;
}

- (BSVolumeControlResult)volumeUp {
    
    const NSUInteger path[] = {4, 8};
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:path length:2];
    NSString *audioDeviceUID;
    
    BSVolumeControlResult result = BSVolumeControlNotSupported;
    
    switch ([self testAudioConfiguration:&audioDeviceUID]) {
        case TAResultTidal:
            
            [self.application pressMenuBarItemForIndexPath:indexPath];
            result = BSVolumeControlUp;
            break;
            
        case TAResultUnavailable:
            
            result = BSVolumeControlUnavailable;
            break;
            
        case TAResultSystemCustom:
            
            result = [self setVolumeWithSign:+1 device:[self audioDeviceWithUUID:audioDeviceUID]];
            break;
            
        default:
            break;
    }
    
    return result;
}

- (BSVolumeControlResult)volumeMute {
    
    NSString *audioDeviceUID;
    
    BSVolumeControlResult result = BSVolumeControlNotSupported;
    
    switch ([self testAudioConfiguration:&audioDeviceUID]) {
        case TAResultTidal:
            
            result = BSVolumeControlUnavailable;
            break;
            
        case TAResultUnavailable:
            
            result = BSVolumeControlUnavailable;
            break;
            
        case TAResultSystemCustom:
            
            result = [self setMuteWithDevice:[self audioDeviceWithUUID:audioDeviceUID]];
            break;
            
        default:
            break;
    }
    
    return result;
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
        
        NSString *artist = trackMeta[@"artist"][@"name"];
        if ([NSString isNullOrEmpty:artist]) {
            
            //getting artist from 'artists'
            for (NSDictionary *item in trackMeta[@"artists"]) {
                
                if (artist.length) {
                    
                    artist = [artist stringByAppendingFormat:@", %@", item[@"name"]];
                }
                else {
                    artist = item[@"name"];
                }
            }
        }
        
        NSMutableDictionary *trackInfo = [NSMutableDictionary
                                          dictionaryWithDictionary:@{
                                                                     kBSTrackNameTrack: trackMeta[@"title"] ?: @"",
                                                                     kBSTrackNameAlbum: trackMeta[@"album"][@"title"] ?: @"",
                                                                     kBSTrackNameArtist: artist ?: @""
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

- (TAResult)testAudioConfiguration:(NSString **)tidalAudioDeviceUID {
    
    NSNumber *userId = [TidalTabAdapter userMeta][@"id"];
    if (! [userId unsignedIntegerValue]) {
        
        return  TAResultSystem;
    }
    
    __block NSDictionary *result;
    
    //getting selected audio device
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *dbResult = [db executeQuery:[NSString stringWithFormat:@"select * from ItemTable where key = '_TIDAL_%@selectedOutputDevice'", userId]];
        if ([dbResult next]) {
            NSData *data = [dbResult dataNoCopyForColumnIndex:1];
            result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        [dbResult close];
    }];
    
    NSString *tidalAudioOutputDeviceName = result[@"id"];
    
    if ([NSString isNullOrEmpty:tidalAudioOutputDeviceName] || [tidalAudioOutputDeviceName isEqualToString:@"SystemControlled"]) {
        
        return TAResultSystem;
    }
    
    //getting audio device settings
    result = nil;
    [dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *dbResult = [db executeQuery:[NSString stringWithFormat:@"select * from ItemTable where key = '_TIDAL_%@deviceSettings_%@'", userId, tidalAudioOutputDeviceName]];
        if ([dbResult next]) {
            NSData *data = [dbResult dataNoCopyForColumnIndex:1];
            result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        [dbResult close];
    }];
    
    if ([result[@"mode"] isEqualToString:@"exclusive"]) {
        
        // if Tidal has exclusive access
        if ([result[@"forceVolume"] boolValue]) {
            
            // if thare is external volume controller
            return TAResultUnavailable;
        }
        
        return TAResultTidal;
    }
    
    
    // checking that Tidal audio output is not equal system default output
    AudioDeviceID theDefaultOutputDeviceID;
    UInt32 thePropSize = sizeof(theDefaultOutputDeviceID);
    
    AudioObjectPropertyAddress thePropertyAddress = { kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    
    // get the ID of the default output device
    OSStatus osResult = AudioObjectGetPropertyData(kAudioObjectSystemObject, &thePropertyAddress, 0, NULL, &thePropSize, &theDefaultOutputDeviceID);
    if (osResult == 0){
        
        CFStringRef theDefaultOutputDeviceName;
        thePropSize = sizeof(theDefaultOutputDeviceName);
        
        thePropertyAddress.mSelector = kAudioDevicePropertyDeviceUID;
        thePropertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
        thePropertyAddress.mElement = kAudioObjectPropertyElementMaster;
        
        // get the name of the default output device
        osResult = AudioObjectGetPropertyData(theDefaultOutputDeviceID, &thePropertyAddress, 0, NULL, &thePropSize, &theDefaultOutputDeviceName);
        if (osResult == 0) {
            
            NSString *defaultOutputDeviceName = CFBridgingRelease(theDefaultOutputDeviceName);
            if (! [defaultOutputDeviceName isEqualToString:tidalAudioOutputDeviceName]) {
                
                if (tidalAudioDeviceUID) {
                    *tidalAudioDeviceUID = tidalAudioOutputDeviceName;
                }
                return TAResultSystemCustom;
            }
        }
    }
    
    return TAResultSystem;
}

- (BSVolumeControlResult)setVolumeWithSign:(Float32)volumeSign device:(AudioDeviceID)audioDevice {
    
    if (volumeSign && audioDevice != kAudioDeviceUnknown) {
        
        Float32 theVolume = 0;
        UInt32 thePropSize = sizeof(theVolume);
        AudioObjectPropertyAddress thePropertyAddress = { kAudioHardwareServiceDeviceProperty_VirtualMasterVolume, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMaster };

        Boolean settable = false;
        
        // see if the device supports volume control, if so, then set the user specified volume
        OSStatus osResult = AudioObjectIsPropertySettable(audioDevice, &thePropertyAddress, &settable);
        if (osResult || settable == false) {
            
            return BSVolumeControlUnavailable;
        }
        
        osResult = AudioObjectGetPropertyData(audioDevice, &thePropertyAddress, 0, NULL, &thePropSize, &theVolume);
        if (osResult == 0) {
            
            BSVolumeControlResult result = BSVolumeControlNotSupported;
            if (volumeSign < 0) {
                theVolume -= VOLUME_STEP;
                if (theVolume < 0) {
                    theVolume = 0;
                }
                result = BSVolumeControlDown;
            }
            else {
                theVolume += VOLUME_STEP;
                if (theVolume > 1) {
                    theVolume = 1;
                }
                result = BSVolumeControlUp;
            }
            osResult = AudioObjectSetPropertyData(audioDevice, &thePropertyAddress, 0, NULL, thePropSize, &theVolume);
            if (osResult == 0)
                return result;
        }
    }
    
    return BSVolumeControlUnavailable;
}


- (BSVolumeControlResult)setMuteWithDevice:(AudioDeviceID)audioDevice {
    
    if (audioDevice != kAudioDeviceUnknown) {
        
        UInt32 theMute = 0;
        UInt32 thePropSize = sizeof(theMute);
        AudioObjectPropertyAddress thePropertyAddress = { kAudioDevicePropertyMute, kAudioDevicePropertyScopeOutput, kAudioObjectPropertyElementMaster };
        
        Boolean settable = false;
        
        // see if the device supports volume control, if so, then set the user specified volume
        OSStatus osResult = AudioObjectIsPropertySettable(audioDevice, &thePropertyAddress, &settable);
        if (osResult || settable == false) {
            
            return BSVolumeControlUnavailable;
        }
        
        osResult = AudioObjectGetPropertyData(audioDevice, &thePropertyAddress, 0, NULL, &thePropSize, &theMute);
        if (osResult == 0) {
            
            BSVolumeControlResult result = BSVolumeControlNotSupported;
            theMute = ! theMute;
            if (theMute) {
                result = BSVolumeControlMute;
            }
            else {
                result = BSVolumeControlUnmute;
            }
            
            osResult = AudioObjectSetPropertyData(audioDevice, &thePropertyAddress, 0, NULL, thePropSize, &theMute);
            if (osResult == 0)
                return result;
        }
    }
    
    return BSVolumeControlUnavailable;
}

- (AudioDeviceID)audioDeviceWithUUID:(NSString *)audioDeviceUID {
    
    // get the device list
    AudioDeviceID result = kAudioDeviceUnknown;
    
    if ([NSString isNullOrEmpty:audioDeviceUID]) {
        
        return result;
    }
    
    UInt32 thePropSize;
    AudioDeviceID *theDeviceList = NULL;
    UInt32 theNumDevices = 0;
    
    AudioObjectPropertyAddress thePropertyAddress = { kAudioHardwarePropertyDevices, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
    OSStatus osResult = AudioObjectGetPropertyDataSize(kAudioObjectSystemObject, &thePropertyAddress, 0, NULL, &thePropSize);
    if (osResult == noErr) {
        
        // Find out how many devices are on the system
        theNumDevices = thePropSize / sizeof(AudioDeviceID);
        theDeviceList = (AudioDeviceID*)calloc(theNumDevices, sizeof(AudioDeviceID));
        
        osResult = AudioObjectGetPropertyData(kAudioObjectSystemObject, &thePropertyAddress, 0, NULL, &thePropSize, theDeviceList);
        if (osResult == noErr) {
            
            CFStringRef theDeviceName;
            // get the device uid
            thePropSize = sizeof(CFStringRef);
            thePropertyAddress.mSelector = kAudioDevicePropertyDeviceUID;
            thePropertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
            thePropertyAddress.mElement = kAudioObjectPropertyElementMaster;
            
            for (UInt32 i=0; i < theNumDevices; i++) {
                @autoreleasepool {
                    
                    osResult = AudioObjectGetPropertyData(theDeviceList[i], &thePropertyAddress, 0, NULL, &thePropSize, &theDeviceName);
                    if (osResult == noErr) {
                        
                        NSString *deviceName = CFBridgingRelease(theDeviceName);
                        if ([audioDeviceUID isEqualToString:deviceName]) {
                            
                            result = theDeviceList[i];
                            break;
                        }
                    }
                }
            }
        }
        
        if (theDeviceList)
            free(theDeviceList);
        
    }
    
    return result;
}

@end
