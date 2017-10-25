//
//  AirfoilSatelliteTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 26.03.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "AirfoilSatelliteTabAdapter.h"
#import "AirfoilSatellite.h"
#import "runningSBApplication.h"
#import "NSString+Utils.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"

#define APPNAME_AIRFOILSTLT         @"Airfoil Satellite"
#define APPID_AIRFOILSTLT           @"com.rogueamoeba.AirfoilSpeakers"

@implementation AirfoilSatelliteTabAdapter {
    
    BOOL _showNotification;
    BOOL _isConnectedPropertyExists;
}

- (id)init {
    
    self = [super init];
    if (self) {
        
        _showNotification = YES;
        
        _isConnectedPropertyExists = NO;
    }
    
    return self;
}

+ (id)tabAdapterWithApplication:(runningSBApplication *)application {
    
    AirfoilSatelliteTabAdapter *tab = [super tabAdapterWithApplication:application];
    if (tab) {
        
        AirfoilSatelliteApplication *app =
        (AirfoilSatelliteApplication *)[application sbApplication];
        
        if (app) {
            
            SBObject *isConnectedObj = [app propertyWithCode:'pCnt'];
            
            if ([isConnectedObj get]) {
                tab->_isConnectedPropertyExists = YES;
            }
        }
        
    }
    
    return tab;
}

+ (NSString *)displayName{
    
    return APPNAME_AIRFOILSTLT;
}

+ (NSString *)bundleId{
    
    return APPID_AIRFOILSTLT;
}

- (NSString *)title {
    
    @autoreleasepool {
        
        AirfoilSatelliteApplication *app =
        (AirfoilSatelliteApplication *)[self.application sbApplication];
        
        NSString *title;
        if (![NSString isNullOrEmpty:app.trackTitle])
            title = app.trackTitle;
        
        if (![NSString isNullOrEmpty:app.artist]) {
            
            if (title)
                title = [title stringByAppendingFormat:@" - %@", app.artist];
            else
                title = app.artist;
        }
        
        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", @"AirfoilSatelliteTabAdapter");
        }
        
        return [NSString stringWithFormat:@"%@ (%@)", title, APPNAME_AIRFOILSTLT];
    }
}
- (NSString *)URL{
    
    return APPID_AIRFOILSTLT;
}

// We have only one window.
- (NSString *)key{
    
    return @"A:" APPID_AIRFOILSTLT;
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{
    
    if (otherTab == nil || ![otherTab isKindOfClass:[AirfoilSatelliteTabAdapter class]]) return NO;
    
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{
    
    AirfoilSatelliteApplication *app = (AirfoilSatelliteApplication *)[self.application sbApplication];
    if (app) {
        [app playpause];
    }
    
    _showNotification = YES;
}
- (void)pause{
    
    AirfoilSatelliteApplication *app = (AirfoilSatelliteApplication *)[self.application sbApplication];
    if (app) {
        if (! [NSString isNullOrEmpty:app.trackTitle]) {
            [app playpause];
        }
    }
    
    _showNotification = YES;
}
- (void)next{
    
    AirfoilSatelliteApplication *app = (AirfoilSatelliteApplication *)[self.application sbApplication];
    if (app) {
        [app next];
    }
    
    _showNotification = NO;
}
- (void)previous{
    
    AirfoilSatelliteApplication *app = (AirfoilSatelliteApplication *)[self.application sbApplication];
    if (app) {
        [app previous];
    }
    
    _showNotification = NO;
}

- (BSTrack *)trackInfo{
    
    AirfoilSatelliteApplication *app = (AirfoilSatelliteApplication *)[self.application sbApplication];
    if (app) {
        
        BSTrack *track = [BSTrack new];
        
        track.track = app.trackTitle;
        track.album = app.album;
        track.artist = app.artist;
        
        
        // bug in 'Airfoil Satewllite' applescript definition,
        // artwork defined as NSData, but this is NSImage
        track.image = (NSImage *) [app artwork];
        
        return track;
    }
    
    return nil;
}

- (BOOL)isPlaying{
    
    AirfoilSatelliteApplication *app = (AirfoilSatelliteApplication *)[self.application sbApplication];
    
    BOOL result = NO;
    if (app) {
        return _isConnectedPropertyExists ?
        app.isConnected
        : ! [NSString isNullOrEmpty:app.trackTitle];
    }
    
    return result;
}


/**
 Returns YES when BeardedSpice must show notofication.
 
 Because Airfoil Satellite works slowly when switches of a tracks,
 we show notification only when play/pause occurs.
 */
- (BOOL)showNotifications{
    return _showNotification;
}

@end
