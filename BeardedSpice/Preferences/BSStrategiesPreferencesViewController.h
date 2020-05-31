//
//  BSStrategiesPreferencesViewController.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 22.05.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "Shortcut.h"

/////////////////////////////////////////////////////////////////////////
#pragma mark Notifications

extern NSString *const BSStrategiesPreferencesNativeAppChangedNoticiation;

/////////////////////////////////////////////////////////////////////////
#pragma mark Defaults Keys

extern NSString *const BeardedSpiceActiveControllers;
extern NSString *const BeardedSpiceActiveNativeAppControllers;

extern NSString *const BeardedSpiceImportExportLastDirectory;

/////////////////////////////////////////////////////////////////////////
#pragma mark - BSStrategiesPreferencesViewController

extern NSString *const StrategiesPreferencesViewController;

@interface BSStrategiesPreferencesViewController : NSViewController <MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate>
{
    // array of MediaControllerObject used to drive the view
    NSArray *mediaControllerObjects;
    
    // dictionary of user preferences
    NSMutableDictionary *userStrategies;
    NSMutableDictionary *userNativeApps;
    
    NSString *_toolTipForCustomStrategy;
}

@property (assign) IBOutlet NSTableView *strategiesView;
@property (weak) IBOutlet NSView *firstResponderView;

@property (readonly) BOOL selectedRowAllowExport;
@property (readonly) BOOL selectedRowAllowRemove;


/////////////////////////////////////////////////////////////////////////
#pragma mark Outlets

@property (weak) IBOutlet NSTextField *unsupportedPrefixTextField;
@property (weak) IBOutlet NSButton *customUpdateButton;
@property (weak) IBOutlet NSButton *customDownloadButton;
@property (weak) IBOutlet NSSearchField *searchField;

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions

- (IBAction)clickExport:(id)sender;
- (IBAction)clickImport:(id)sender;
- (IBAction)clickRemove:(id)sender;
- (IBAction)clickUpdate:(id)sender;
- (IBAction)clickDownload:(id)sender;
- (IBAction)clickSearchField:(id)sender;

/////////////////////////////////////////////////////////////////////////
#pragma mark Public methods ans properties

- (void)importStrategyWithPath:(NSString *)strategyPath;

@end
