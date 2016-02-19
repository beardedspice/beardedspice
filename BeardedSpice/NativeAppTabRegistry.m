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
#import "RadiumTabAdapter.h"

@implementation NativeAppTabRegistry

- (id)initWithUserDefaultsKey:(NSString *)defaultsKey{
    
    self = [super init];
    if (self) {
        
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
    return self;
}

+ (NSArray *)defaultNativeAppClasses {

    return @[

        [iTunesTabAdapter class],
        [SpotifyTabAdapter class],
        [VOXTabAdapter class],
        [RadiumTabAdapter class]
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
