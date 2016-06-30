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
extern NSString *const BeardedSpiceUpdateAtLaunch;

extern NSString *const BeardedSpiceImportExportLastDirectory;

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
    NSString *_toolTipForCustomStrategy;
}

@property (assign) IBOutlet NSTableView *strategiesView;
@property (weak) IBOutlet NSButton *firstResponderView;

@property (readonly) BOOL selectedRowAllowExport;
@property (readonly) BOOL selectedRowAllowRemove;
@property (readonly) BOOL importExportPanelOpened;


/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

- (IBAction)toggleLaunchAtStartup:(id)sender;
- (IBAction)toggleAutoPause:(id)sender;
- (IBAction)toggleUseRemote:(id)sender;
- (IBAction)clickExport:(id)sender;
- (IBAction)clickImport:(id)sender;
- (IBAction)clickRemove:(id)sender;

@end
