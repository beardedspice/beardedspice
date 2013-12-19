//
//  PreferencesWindowController.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/17/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    return self;
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];
    NSLog(@"Show Preferences: %@", [self window]);
}

@end
