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

@implementation NativeAppTabAdapter {
    runningSBApplication *_application;
}

+(id)tabAdapterWithApplication:(runningSBApplication *)application{

    NativeAppTabAdapter *tab = [[self class] new];

    tab->_application = application;
    return tab;
}

+ (NSString *)displayName{
    return nil;
}

+ (NSString *)bundleId{
    return nil;
}

- (runningSBApplication *)application {
    return _application;
}

- (void)toggleTab {
    if (! [self deactivateApp]) {
        [self activateApp];
    }
}

@end

#pragma clang diagnostic pop
