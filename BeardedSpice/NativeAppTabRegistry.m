//
//  NativeAppTabRegistry.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 01.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NativeAppTabRegistry.h"

#import "iTunesTabAdapter.h"
#import "SpotifyTabAdapter.h"
#import "VOXTabAdapter.h"
#import "VLCTabAdapter.h"
#import "DowncastTabAdapter.h"
#import "AirfoilSatelliteTabAdapter.h"
#import "TidalTabAdapter.h"
#import "BeaTunesTabAdapter.h"

@implementation NativeAppTabRegistry


static NativeAppTabRegistry *singletonNativeAppTabRegistry;

/////////////////////////////////////////////////////////////////////
#pragma mark Initialize

+ (NativeAppTabRegistry *)singleton{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        singletonNativeAppTabRegistry = [NativeAppTabRegistry alloc];
        singletonNativeAppTabRegistry = [singletonNativeAppTabRegistry init];
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

    for (Class appClass in defaultApps) {
        NSString *name = [appClass displayName];
        if (name) {
            NSNumber *enabled = [defaults objectForKey:name];
            if (!enabled || [enabled boolValue]) {
                [self enableNativeAppClass:appClass];
            }
        }
    }

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
        [BeaTunesTabAdapter class]
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
}

- (void)disableNativeAppClass:(Class)appClass{

    @synchronized(self){

        [_availableAppClasses removeObject:appClass];
        [_availableCache removeObjectForKey:[appClass bundleId]];
    }
}

@end
