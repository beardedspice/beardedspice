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
#import "NativeAppTabRegistry.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications
/////////////////////////////////////////////////////////////////////////

extern NSString *const GeneralPreferencesNativeAppChangedNoticiation;

/////////////////////////////////////////////////////////////////////////
#pragma mark Defaults Keys
/////////////////////////////////////////////////////////////////////////

extern NSString *const BeardedSpiceAlwaysShowNotification;
extern NSString *const BeardedSpiceActiveControllers;
extern NSString *const BeardedSpiceActiveNativeAppControllers;
extern NSString *const BeardedSpiceITunesIntegration;

/////////////////////////////////////////////////////////////////////////
#pragma mark - GeneralPreferencesViewController
/////////////////////////////////////////////////////////////////////////

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate>
{
    // array of MediaControllerObject used to drive the view
    NSArray *mediaControllerObjects;

    // dictionary of user preferences
    NSMutableDictionary *userStrategies;
    NSMutableDictionary *userNativeApps;

    NSNumber *alwaysShow;

    // shared registry object for controlling behavior
    MediaStrategyRegistry *strategyRegistry;
    NativeAppTabRegistry *nativeRegistry;
}

@property (assign) IBOutlet NSTableView *strategiesView;

- (id)initWithMediaStrategyRegistry:(MediaStrategyRegistry *)mediaStrategyRegistry nativeAppTabRegistry:(NativeAppTabRegistry *)nativeAppTabRegistry;

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

@end
