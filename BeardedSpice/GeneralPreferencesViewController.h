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
extern NSString *const BeardedSpiceSwitchTabShortcut;
extern NSString *const BeardedSpiceActiveControllers;

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate>
{
    // array of strategies used to drive the view
    NSArray *availableStrategies;
    
    // dictionary of user preferences
    NSMutableDictionary *userStrategies;
    
    // shared registry object for controlling behavior
    MediaStrategyRegistry *registry;
}

@property (nonatomic, weak) IBOutlet MASShortcutView *activeShortcutView;
@property (nonatomic, weak) IBOutlet MASShortcutView *switchShortcutView;
@property (assign) IBOutlet NSTableView *strategiesView;

- (id)initWithMediaStrategyRegistry:(MediaStrategyRegistry *)mediaStrategyRegistry;

@end
