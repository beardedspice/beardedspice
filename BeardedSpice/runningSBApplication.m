//
//  runningApplication.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 07.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "runningSBApplication.h"

@implementation runningSBApplication

- (instancetype)initWithApplication:(SBApplication *)application bundleIdentifier:(NSString *)bundleIdentifier{
    
    self = [super init];
    if (self) {
        
        _sbApplication = application;
        _bundleIdentifier = bundleIdentifier;
    }
    
    return self;
}

- (BOOL)frontmost{
    
    NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
    return [frontmostApp.bundleIdentifier isEqualToString:self.bundleIdentifier];
}

@end
