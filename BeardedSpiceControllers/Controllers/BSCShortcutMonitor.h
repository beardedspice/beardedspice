//
//  BSCShortcutMonitor.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.03.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MASShortcut;

@interface BSCShortcutMonitor : NSObject

+ (instancetype) sharedMonitor;

- (BOOL) registerShortcut: (MASShortcut*) shortcut withAction: (dispatch_block_t) action;
- (void) unregisterShortcut: (MASShortcut*) shortcut;
- (void) unregisterAllShortcuts;

@end
