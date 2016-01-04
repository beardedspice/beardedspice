//
//  NativeAppTabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 26.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NativeAppTabAdapter.h"
#import "runningSBApplication.h"

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

// Method stubs to satisfy the TapAdapter protocol
- (void) toggle {
}

- (void) pause {
}

- (void) next {
}

- (void) previous {
}

- (void) favorite {
}

- (Track *) trackInfo {
    return nil;
}

- (BOOL)isPlaying {
    return NO;
}

- (BOOL)showNotifications{
    return YES;
}


@end
