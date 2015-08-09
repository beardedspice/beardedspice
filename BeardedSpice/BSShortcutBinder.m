//
//  BSShortcutBinder.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 09.08.15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//

#import "BSShortcutBinder.h"

@interface MASShortcutBinder ()

@property(strong) NSMutableDictionary *actions;
@property(strong) NSMutableDictionary *shortcuts;

- (BOOL) isRegisteredAction: (NSString*) name;

@end

@implementation BSShortcutBinder

- (void) setValue: (id) value forUndefinedKey: (NSString*) key
{
    if (![self isRegisteredAction:key]) {
        [super setValue:value forUndefinedKey:key];
        return;
    }
    
    MASShortcut *newShortcut = value;
    MASShortcut *currentShortcut = [self.shortcuts objectForKey:key];
    
    // Unbind previous shortcut if any
    if (currentShortcut != nil) {
        [self.shortcutMonitor unregisterShortcut:currentShortcut];
    }
    
    // Just deleting the old shortcut
    if (newShortcut == nil) {
        [self.shortcuts removeObjectForKey:key];
        return;
    }
    
    // Bind new shortcut
    [self.shortcuts setObject:newShortcut forKey:key];
    [self.shortcutMonitor registerShortcut:newShortcut withAction:[self.actions objectForKey:key]];
}

@end
