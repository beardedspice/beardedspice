//
//  NativeAppTabsRegistry.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 01.05.15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "NativeAppTabsRegistry.h"
#import "BSStrategiesPreferencesViewController.h"

#import "iTunesTabAdapter.h"
#import "SpotifyTabAdapter.h"
#import "VOXTabAdapter.h"
#import "VLCTabAdapter.h"
#import "DowncastTabAdapter.h"
#import "AirfoilSatelliteTabAdapter.h"
#import "TidalTabAdapter.h"
#import "DeezerTabAdapter.h"
#import "BSMusicTabAdapter.h"
#import "BSTVTabAdapter.h"
#import "AmazonMusicTabAdapter.h"
#import "QuodLibetTabAdapter.h"

NSString *BSNativeAppTabsRegistryChangedNotification = @"BSNativeAppTabsRegistryChangedNotification";

@implementation NativeAppTabsRegistry


static NativeAppTabsRegistry *singletonNativeAppTabsRegistry;

/////////////////////////////////////////////////////////////////////
#pragma mark Initialize

+ (NativeAppTabsRegistry *)singleton{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        singletonNativeAppTabsRegistry = [NativeAppTabsRegistry alloc];
        singletonNativeAppTabsRegistry = [singletonNativeAppTabsRegistry init];
        
        [singletonNativeAppTabsRegistry setUserDefaultsKey:BeardedSpiceActiveNativeAppControllers];
    });

    return singletonNativeAppTabsRegistry;

}

- (id)init{

    if (singletonNativeAppTabsRegistry != self) {
        return nil;
    }
    self = [super init];

    return self;
}

- (void)setUserDefaultsKey:(NSString *)defaultsKey{

    _availableAppClasses = [NSMutableArray array];
    _availableCache = [NSMutableDictionary dictionary];

    NSArray *defaultApps = [NativeAppTabsRegistry defaultNativeAppClasses];
    NSDictionary *defaults = [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultsKey];

    @synchronized(self){
        for (Class appClass in defaultApps) {
            NSString *name = [appClass displayName];
            if (name) {
                NSNumber *enabled = [defaults objectForKey:name];
                if (!enabled || [enabled boolValue]) {
                    
                    [_availableAppClasses addObject:appClass];
                    _availableCache[[appClass bundleId]] = appClass;
                }
            }
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BSNativeAppTabsRegistryChangedNotification object:self];
    });

}

/////////////////////////////////////////////////////////////////////
#pragma mark Methods

+ (NSArray *)defaultNativeAppClasses {

    return @[
        [iTunesTabAdapter class],
        [SpotifyTabAdapter class],
        [VLCTabAdapter class],
        [VOXTabAdapter class],
        [DowncastTabAdapter class],
        [AirfoilSatelliteTabAdapter class],
        [DeezerTabAdapter class],
        [BSMusicTabAdapter class],
        [BSTVTabAdapter class],
        [AmazonMusicTabAdapter class],
        [QuodLibetTabAdapter class],
        [TidalTabAdapter class]
    ];
}

- (NSArray *)enabledNativeAppClasses{

    @synchronized(self){
    return [_availableAppClasses copy];
    }
}

- (Class)classForBundleId:(NSString *)bundleId{

    @synchronized(self){
        return _availableCache[bundleId];
    }
}

- (void)enableNativeAppClass:(Class)appClass{

    @synchronized(self){

        [_availableAppClasses addObject:appClass];
        _availableCache[[appClass bundleId]] = appClass;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BSNativeAppTabsRegistryChangedNotification object:self];
    });
}

- (void)disableNativeAppClass:(Class)appClass{

    @synchronized(self){

        [_availableAppClasses removeObject:appClass];
        [_availableCache removeObjectForKey:[appClass bundleId]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BSNativeAppTabsRegistryChangedNotification object:self];
    });
}

@end
