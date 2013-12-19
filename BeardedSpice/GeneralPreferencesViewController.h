//
//  GeneralPreferencesViewController.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/18/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "MASShortcutView+UserDefaults.h"

extern NSString *const BeardedSpiceActiveTabShortcut;

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;

@end
