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

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications
/////////////////////////////////////////////////////////////////////////

extern NSString *const GeneralPreferencesAutoPauseChangedNoticiation;
extern NSString *const GeneralPreferencesUsingAppleRemoteChangedNoticiation;

/////////////////////////////////////////////////////////////////////////
#pragma mark Defaults Keys
/////////////////////////////////////////////////////////////////////////

extern NSString *const BeardedSpiceAlwaysShowNotification;
extern NSString *const BeardedSpiceRemoveHeadphonesAutopause;
extern NSString *const BeardedSpiceUsingAppleRemote;
extern NSString *const BeardedSpiceLaunchAtLogin;
extern NSString *const BeardedSpiceUpdateAtLaunch;
extern NSString *const BeardedSpiceShowProgress;
extern NSString *const BeardedSpiceCustomVolumeControl;

/////////////////////////////////////////////////////////////////////////
#pragma mark - GeneralPreferencesViewController
/////////////////////////////////////////////////////////////////////////

@interface GeneralPreferencesViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSButton *firstResponderView;

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions

- (IBAction)toggleLaunchAtStartup:(id)sender;
- (IBAction)toggleAutoPause:(id)sender;
- (IBAction)toggleUseRemote:(id)sender;
@end
