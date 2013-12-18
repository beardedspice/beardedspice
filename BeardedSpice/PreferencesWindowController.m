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
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSLog(@"Preferences loads");
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];
    
    NSLog(@"Show Preferences: %@", [self window]);
}

@end
