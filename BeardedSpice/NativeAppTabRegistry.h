//
//  NativeAppTabRegistry.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 01.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NativeAppTabAdapter.h"

@interface NativeAppTabRegistry : NSObject{
    
    NSMutableArray *_availableAppClasses;
    NSMutableDictionary *_availableCache;
}

- (id)initWithUserDefaultsKey:(NSString *)defaultsKey;

+ (NSArray *)defaultNativeAppClasses;
- (NSArray *)enabledNativeAppClasses;
- (Class)classForBundleId:(NSString *)bundleId;

- (void)enableNativeAppClass:(Class)appClass;
- (void)disableNativeAppClass:(Class)appClass;

@end
