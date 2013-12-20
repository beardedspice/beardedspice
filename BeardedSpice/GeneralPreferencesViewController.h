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
#import "MediaStrategyRegistry.h"

extern NSString *const BeardedSpiceActiveTabShortcut;
extern NSString *const BeardedSpiceActiveControllers;

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate>
{
    NSArray *availableStrategies;
    MediaStrategyRegistry *registry;
}

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (assign) IBOutlet NSTableView *strategiesView;

- (id)initWithMediaStrategyRegistry:(MediaStrategyRegistry *)mediaStrategyRegistry;

@end
