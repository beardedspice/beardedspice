//
//  NativeAppTabsRegistry.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 01.05.15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>
#import "BSNativeAppTabAdapter.h"

extern NSString *BSNativeAppTabsRegistryChangedNotification;

@interface NativeAppTabsRegistry : NSObject{
    
    NSMutableArray *_availableAppClasses;
    NSMutableDictionary *_availableCache;
}

+ (NativeAppTabsRegistry *)singleton;
- (void)setUserDefaultsKey:(NSString *)defaultsKey;

+ (NSArray *)defaultNativeAppClasses;
- (NSArray *)enabledNativeAppClasses;
- (Class)classForBundleId:(NSString *)bundleId;

- (void)enableNativeAppClass:(Class)appClass;
- (void)disableNativeAppClass:(Class)appClass;

@end
