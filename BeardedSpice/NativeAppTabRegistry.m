//
//  NativeAppTabRegistry.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 01.05.15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "NativeAppTabRegistry.h"
#import "BSStrategiesPreferencesViewController.h"

#import "iTunesTabAdapter.h"
#import "SpotifyTabAdapter.h"
#import "VOXTabAdapter.h"
#import "VLCTabAdapter.h"
#import "DowncastTabAdapter.h"
#import "AirfoilSatelliteTabAdapter.h"
#import "TidalTabAdapter.h"
#import "DeezerTabAdapter.h"

NSString *BSNativeAppTabRegistryChangedNotification = @"BSNativeAppTabRegistryChangedNotification";

@implementation NativeAppTabRegistry


static NativeAppTabRegistry *singletonNativeAppTabRegistry;

/////////////////////////////////////////////////////////////////////
#pragma mark Initialize

+ (NativeAppTabRegistry *)singleton{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        singletonNativeAppTabRegistry = [NativeAppTabRegistry alloc];
        singletonNativeAppTabRegistry = [singletonNativeAppTabRegistry init];
        
        [singletonNativeAppTabRegistry setUserDefaultsKey:BeardedSpiceActiveNativeAppControllers];
    });

    return singletonNativeAppTabRegistry;

}

- (id)init{

    if (singletonNativeAppTabRegistry != self) {
        return nil;
    }
    self = [super init];

    return self;
}

- (void)setUserDefaultsKey:(NSString *)defaultsKey{

    _availableAppClasses = [NSMutableArray array];
    _availableCache = [NSMutableDictionary dictionary];

    NSArray *defaultApps = [NativeAppTabRegistry defaultNativeAppClasses];
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
         postNotificationName:BSNativeAppTabRegistryChangedNotification object:self];
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
        [TidalTabAdapter class],
        [DeezerTabAdapter class]
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
         postNotificationName:BSNativeAppTabRegistryChangedNotification object:self];
    });
}

- (void)disableNativeAppClass:(Class)appClass{

    @synchronized(self){

        [_availableAppClasses removeObject:appClass];
        [_availableCache removeObjectForKey:[appClass bundleId]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:BSNativeAppTabRegistryChangedNotification object:self];
    });
}

@end
