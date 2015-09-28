//
//  GeneralPreferencesViewController.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/18/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "Shortcut.h"
#import "MediaStrategyRegistry.h"
#import "NativeAppTabRegistry.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications
/////////////////////////////////////////////////////////////////////////

extern NSString *const GeneralPreferencesNativeAppChangedNoticiation;
extern NSString *const GeneralPreferencesAutoPauseChangedNoticiation;
extern NSString *const GeneralPreferencesUsingAppleRemoteChangedNoticiation;

/////////////////////////////////////////////////////////////////////////
#pragma mark Defaults Keys
/////////////////////////////////////////////////////////////////////////

extern NSString *const BeardedSpiceAlwaysShowNotification;
extern NSString *const BeardedSpiceActiveControllers;
extern NSString *const BeardedSpiceActiveNativeAppControllers;
extern NSString *const BeardedSpiceRemoveHeadphonesAutopause;
extern NSString *const BeardedSpiceUsingAppleRemote;
extern NSString *const BeardedSpiceLaunchAtLogin;

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
@property (weak) IBOutlet NSButton *firstResponderView;

- (id)initWithMediaStrategyRegistry:(MediaStrategyRegistry *)mediaStrategyRegistry nativeAppTabRegistry:(NativeAppTabRegistry *)nativeAppTabRegistry;

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

- (IBAction)toggleLaunchAtStartup:(id)sender;
- (IBAction)toggleAutoPause:(id)sender;
- (IBAction)toggleUseRemote:(id)sender;

@end
