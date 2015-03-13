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

extern NSString *const BeardedSpiceAlwaysShowNotification;
extern NSString *const BeardedSpiceActiveControllers;

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate>
{
    // array of strategies used to drive the view
    NSArray *availableStrategies;

    // dictionary of user preferences
    NSMutableDictionary *userStrategies;

    NSNumber *alwaysShow;

    // shared registry object for controlling behavior
    MediaStrategyRegistry *registry;
}

@property (nonatomic, weak) IBOutlet NSButtonCell *alwaysShowNotification;
@property (assign) IBOutlet NSTableView *strategiesView;

- (id)initWithMediaStrategyRegistry:(MediaStrategyRegistry *)mediaStrategyRegistry;

@end
