//
//  BSNativeAppTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 26.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "BSNativeAppTabAdapter.h"
#import "runningSBApplication.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation BSNativeAppTabAdapter {
    runningSBApplication *_application;
}

+(id)tabAdapterWithApplication:(runningSBApplication *)application{

    BSNativeAppTabAdapter *tab = [[self class] new];

    tab->_application = application;
    return tab;
}

+ (NSString *)bundleId{
    return nil;
}

+ (NSString *)displayName{
    NSString *bundleId = [self bundleId];
    if (bundleId.length) {
        NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleId];
        if (path.length) {
            return [[[[NSFileManager defaultManager]
                      displayNameAtPath:path]
                     lastPathComponent]
                    stringByDeletingPathExtension];
            
        }
    }
    
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
