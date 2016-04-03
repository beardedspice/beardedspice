//
//  NativeAppTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 26.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NativeAppTabAdapter.h"
#import "runningSBApplication.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation NativeAppTabAdapter

+(id)tabAdapterWithApplication:(runningSBApplication *)application{
    
    NativeAppTabAdapter *tab = [[self class] new];
    
    tab.application = application;
    return tab;
}

+ (NSString *)displayName{
    return nil;
}

+ (NSString *)bundleId{
    return nil;
}

- (BOOL)showNotifications{
    return YES;
}


@end

#pragma clang diagnostic pop