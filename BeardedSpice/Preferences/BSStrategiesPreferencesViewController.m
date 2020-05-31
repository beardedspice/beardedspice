//
//  BSStrategiesPreferencesViewController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 22.05.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSStrategiesPreferencesViewController.h"
#import "MediaStrategyRegistry.h"
#import "NativeAppTabsRegistry.h"
#import "MediaControllerObject.h"
#import "BSMediaStrategyEnableButton.h"
#import "BSMediaStrategy.h"
#import "BSStrategyCache.h"
#import "BSStrategyVersionManager.h"
#import "EHVerticalCenteredTextField.h"
#import "BSCustomStrategyManager.h"
#import "AppDelegate.h"


NSString *const BSStrategiesPreferencesNativeAppChangedNoticiation = @"BSStrategiesPreferencesNativeAppChangedNoticiation";
NSString *const BeardedSpiceActiveControllers = @"BeardedSpiceActiveControllers";
NSString *const BeardedSpiceActiveNativeAppControllers = @"BeardedSpiceActiveNativeAppControllers";
NSString *const BeardedSpiceImportExportLastDirectory = @"BeardedSpiceImportExportLastDirectory";
NSString *const StrategiesPreferencesViewController = @"StrategiesPreferencesViewController";


@interface BSStrategiesPreferencesViewController ()

@property BOOL selectedRowAllowExport;
@property BOOL selectedRowAllowRemove;

@end

@implementation BSStrategiesPreferencesViewController {
   NSArray <MediaControllerObject *> *_mediaControllerObjectsCache;
}

- (id)init{
    
    self = [super initWithNibName:@"BSStrategiesPreferencesViewController" bundle:nil];
    if (self) {
        
        _toolTipForCustomStrategy = BSLocalizedString(
                                                      @"This strategy is user custom defined.",
                                                      @"(GeneralPreferencesViewController) In preferences, strategies "
                                                      @"list. ToolTip for row, which meens that this strategy is user "
                                                      @"defined.");
        
        self.selectedRowAllowExport = self.selectedRowAllowRemove = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(strategyChangedNotify:) name: BSVMStrategyChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(strategyChangedNotify:) name: BSCStrategyChangedNotification object:nil];
        [self loadMediaControllerObjects];
    }
    return self;
}

- (void)dealloc{
    
}

- (void)viewDidLoad {
    // sets links
    NSAttributedString *linkString = [self.unsupportedPrefixTextField.stringValue
                                      attributedStringFromTemplateInsertingLink:@[[NSURL URLWithString:BS_UNSUPPORTED_STRATEGY_REPO_URL]]
                                      alignment:self.unsupportedPrefixTextField.alignment
                                      font:self.unsupportedPrefixTextField.font
                                      color:self.unsupportedPrefixTextField.textColor];
    if (linkString) {
        self.unsupportedPrefixTextField.selectable = YES;
        self.unsupportedPrefixTextField.allowsEditingTextAttributes = YES;
        [self.unsupportedPrefixTextField setAttributedStringValue:linkString];
    }
}

- (NSString *)viewIdentifier
{
    return StrategiesPreferencesViewController;
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return BSLocalizedString(@"Controllers", @"Toolbar item name for the Media Controllers preference pane");
}

- (NSView *)initialKeyView{
    
    return self.firstResponderView;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Public methods and properties

- (void)importStrategyWithPath:(NSString *)strategyPath {
    
    NSURL *strategyUrl = [NSURL fileURLWithPath:strategyPath];
    if (strategyUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self importStrategyWithUrl:strategyUrl];
        });
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions

- (IBAction)clickExport:(id)sender {
    
        @autoreleasepool {
            
            BSMediaStrategy *strategy = [self strategyFromTableSelection];
            if (strategy) {
                
                NSOpenPanel *openPanel = [NSOpenPanel openPanel];
                
                openPanel.directoryURL =
                [self importExportDirectoryForCustomStrategy];
                openPanel.allowedFileTypes = nil;
                openPanel.allowsOtherFileTypes = NO;
                openPanel.canChooseFiles = NO;
                openPanel.canChooseDirectories = YES;
                openPanel.canCreateDirectories = YES;
                openPanel.allowsMultipleSelection = NO;
                openPanel.title = BSLocalizedString(@"preferences-strategies-export-select-folder-title",@"");
                openPanel.prompt = BSLocalizedString(@"preferences-strategies-export-select-folder-button-title", @"");
                
                [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
                    
                    if (result == NSModalResponseOK) {
                        
                        // export to file
                        NSURL *fileURL = openPanel.URL;
                        [[NSUserDefaults standardUserDefaults]
                         setObject:[fileURL path]
                         forKey:BeardedSpiceImportExportLastDirectory];
                        
                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                            NSCondition *lk = [NSCondition new];
                            [[BSCustomStrategyManager singleton] exportStrategy:strategy
                                                                       toFolder:fileURL
                                                                      overwrite:^BOOL(NSURL *pathToFile) {
                                [lk lock];
                                __block BOOL result = YES;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSAlert *alert = [NSAlert new];
                                    alert.alertStyle = NSAlertStyleInformational;
                                    alert.messageText = [NSString
                                                         stringWithFormat:BSLocalizedString(
                                                                                            @"File \"%@\" exists.\nDo you want overwrite?",
                                                                                            @"(BSCustomStrategyManager) Title on message, "
                                                                                            @"when file exists."),
                                                         [pathToFile lastPathComponent]];
                                    [alert
                                     addButtonWithTitle:BSLocalizedString(@"Cancel", @"Cancel button")];
                                    
                                    [alert addButtonWithTitle:BSLocalizedString(@"Overwrite",
                                                                                @"Overwrite button")];
                                    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                                        [lk lock];
                                        if (returnCode == NSAlertFirstButtonReturn) {
                                            result = NO;
                                        };
                                        [lk broadcast];
                                        [lk unlock];
                                    }];
                                    
                                });
                                [lk wait];
                                [lk unlock];
                                return result;
                                
                            }
                                                                     completion:^(NSURL *pathToFile, NSError *error) {
                                if (error) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        NSAlert *alert = [NSAlert new];
                                        alert.alertStyle = NSAlertStyleCritical;
                                        alert.informativeText = error.localizedDescription;
                                        alert.messageText =
                                        [NSString stringWithFormat:
                                         BSLocalizedString(
                                                           @"Can't export \"%@\" strategy.",
                                                           @"(BSCustomStrategyManager) Title on message, "
                                                           @"when strategy export error occured."),
                                         strategy.displayName];
                                        [alert addButtonWithTitle:BSLocalizedString(@"Ok", @"Ok button")];
                                        
                                        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
                                        
                                    });
                                }
                                else if (pathToFile) {
                                    [[NSWorkspace sharedWorkspace]
                                     activateFileViewerSelectingURLs:@[ pathToFile ]];
                                }
                            }];
                        });
                    }
                }];
            }
        }
}

- (IBAction)clickImport:(id)sender {
    
    @autoreleasepool {
        
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        
        openPanel.directoryURL =
        [self importExportDirectoryForCustomStrategy];
        openPanel.allowedFileTypes = @[ @"js", BS_STRATEGY_EXTENSION ];
        openPanel.allowsOtherFileTypes = NO;
        openPanel.canChooseFiles = YES;
        openPanel.canChooseDirectories = NO;
        openPanel.canCreateDirectories = NO;
        openPanel.allowsMultipleSelection = NO;
        openPanel.title =
        BSLocalizedString(@"BeardedSpice - Choose a file for importing",
                          @"(GeneralPreferencesViewController) In "
                          @"preferences, strategies list. Title of the "
                          @"panel for choosing of the importing file.");
        openPanel.prompt = BSLocalizedString(
                                             @"Import", @"(GeneralPreferencesViewController) In "
                                             @"preferences, strategies list. 'Choose folder for "
                                             @"importing' panel. Import button title.");
        
        [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
            
            if (result == NSModalResponseOK) {
                
                NSURL *fileURL = openPanel.URL;
                [[NSUserDefaults standardUserDefaults]
                 setObject:[openPanel.directoryURL path]
                 forKey:BeardedSpiceImportExportLastDirectory];
                
                [self importStrategyWithUrl:fileURL];
            }
        }];
    }
}

- (IBAction)clickSearchField:(id)sender {
    [self applySearchField];
    [self.strategiesView reloadData];
}

- (IBAction)clickDownload:(id)sender {
    @autoreleasepool {
        
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        
        openPanel.directoryURL =
        [self importExportDirectoryForCustomStrategy];
        openPanel.allowedFileTypes = nil;
        openPanel.allowsOtherFileTypes = NO;
        openPanel.canChooseFiles = NO;
        openPanel.canChooseDirectories = YES;
        openPanel.canCreateDirectories = YES;
        openPanel.allowsMultipleSelection = NO;
        openPanel.title = BSLocalizedString(@"preferences-strategies-unsupported-download-select-folder-title", @"");
        openPanel.prompt = BSLocalizedString(@"preferences-strategies-unsupported-download-select-folder-button-title", @"");
        
        [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
            
            if (result == NSModalResponseOK) {
                
                // download to folder
                NSURL *folderUrl = openPanel.URL;
                [[NSUserDefaults standardUserDefaults]
                 setObject:[folderUrl path]
                 forKey:BeardedSpiceImportExportLastDirectory];
                
                [[BSCustomStrategyManager singleton] downloadCustomStrategiesFromUnsupportedRepoTo:folderUrl
                                                                                        completion:^(NSURL *savedUrl, NSError *error) {
                    if (error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            NSAlert *alert = [NSAlert new];
                            alert.alertStyle = NSAlertStyleCritical;
                            alert.informativeText = error.localizedDescription;
                            alert.messageText = BSLocalizedString(@"preferences-strategies-unsupported-download-error-alert-message-text", @"");
                            [alert addButtonWithTitle:BSLocalizedString(@"Ok", @"Ok button")];
                            
                            [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
                            
                        });
                    }
                    else if (savedUrl) {
                        [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:savedUrl.path];
                    }
                    
                }];
            }
        }];
    }
}

- (IBAction)clickUpdate:(id)sender {
    @autoreleasepool {
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSAlertStyleWarning;
        alert.informativeText = BSLocalizedString(@"preferences-strategies-unsupported-update-alert-text", @"");
        alert.messageText = BSLocalizedString(@"preferences-strategies-unsupported-update-alert-title", @"");
        [alert addButtonWithTitle:BSLocalizedString(@"Cancel",
                                                    @"Cancel button")];
        [alert addButtonWithTitle:BSLocalizedString(@"button-title-update",@"")];
        
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertSecondButtonReturn) {
                [APPDELEGATE setInUpdatingStrategiesState:YES];
                self.customUpdateButton.title = BSLocalizedString(@"preferences-strategies-unsupported-update-button-title-in-action", @"");
                [[BSCustomStrategyManager singleton] updateCustomStrategiesFromUnsupportedRepoWithCompletion:^(NSArray<NSString *> *updatedNames, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.customUpdateButton.title = BSLocalizedString(@"preferences-strategies-unsupported-update-button-title", @"");
                        NSUserNotification *notification = [NSUserNotification new];
                        notification.title = BSLocalizedString(@"Compatibility Updates", @"");
                        notification.subtitle = [NSString stringWithFormat:BSLocalizedString(@"update-custom-strategy", @""), updatedNames.count];
                        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                        [APPDELEGATE setInUpdatingStrategiesState:NO];
                    });
                }];
            }
        }];
    }
}

- (IBAction)clickRemove:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        @autoreleasepool {
            
            BSMediaStrategy *strategy = [self strategyFromTableSelection];
            if (strategy) {
                
                NSAlert *alert = [NSAlert new];
                alert.alertStyle = NSAlertStyleInformational;
                alert.informativeText = strategy.description;
                alert.messageText = [NSString
                                     stringWithFormat:
                                     BSLocalizedString(
                                                       @"Are you realy want remove \"%@\" strategy?",
                                                       @"(GeneralPreferencesViewController) In preferences, "
                                                       @"strategies list."
                                                       @"Title of the question about remove."),
                                     strategy.displayName];
                [alert addButtonWithTitle:BSLocalizedString(@"Cancel",
                                                            @"Cancel button")];
                [alert addButtonWithTitle:BSLocalizedString(@"Remove",
                                                            @"Remove button")];
                
                [alert beginSheetModalForWindow:self.view.window
                              completionHandler:^(NSModalResponse returnCode) {
                    if (returnCode == NSAlertSecondButtonReturn) {
                        [APPDELEGATE setInUpdatingStrategiesState:YES];
                        [[BSCustomStrategyManager singleton] removeStrategy:strategy
                                                                 completion:^(BSMediaStrategy *replacedStrategy, NSError *error) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                NSAlert *alert = [NSAlert new];
                                if (error) {
                                    alert.alertStyle = NSAlertStyleCritical;
                                    alert.informativeText = error.localizedDescription;
                                    alert.messageText =
                                    [NSString stringWithFormat:
                                     BSLocalizedString(
                                                       @"Can't remove \"%@\" strategy.",
                                                       @"(BSCustomStrategyManager) Title "
                                                       @"on message, when strategy remove "
                                                       @"error occured."),
                                     strategy.displayName];
                                }
                                else {
                                    
                                    [self updateStrategiesView];

                                    alert.alertStyle = NSAlertStyleInformational;
                                    alert.informativeText = [strategy description];
                                    alert.messageText =
                                    [NSString stringWithFormat:
                                     BSLocalizedString(
                                                       @"Strategy \"%@\" removed successfuly.",
                                                       @"(BSCustomStrategyManager) Title on message, "
                                                       @"when strategy import error occured."),
                                     strategy.displayName];
                                }
                                [alert addButtonWithTitle:BSLocalizedString(@"Ok", @"Ok button")];
                                
                                [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                                    [self selectStrategy:replacedStrategy];
                                    [APPDELEGATE setInUpdatingStrategiesState:NO];
                                }];
                            });
                        }];
                    }
                }];
            }
        }
    });
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
/////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return mediaControllerObjects.count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row{
    
    return [mediaControllerObjects[row] isGroup];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)row{
    
    return ![mediaControllerObjects[row] isGroup];
    
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    
    return ([mediaControllerObjects[row] isGroup] ? 18.0 : 25.0);
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    MediaControllerObject *obj = mediaControllerObjects[row];
    
    // Create group
    if (obj.isGroup) {
        
        NSTextField *result = [tableView makeViewWithIdentifier:@"GroupView" owner:self];
        
        // there is no existing cell to reuse so create a new one
        if (result == nil) {
            result = [NSTextField new];
            
            // this allows the cell to be reused.
            result.identifier = @"GroupView";
            result.alignment = NSTextAlignmentCenter;
            result.selectable = NO;
            result.editable = NO;
            result.bordered = NO;
            result.bezeled = NO;
            result.refusesFirstResponder = YES;
            result.backgroundColor = [NSColor colorWithCalibratedWhite:1 alpha:0.4];
            result.textColor = [NSColor headerColor];
            result.font = [NSFont boldSystemFontOfSize:12];
        }
        
        [result setStringValue:obj.name];
        return result;
    }
    
    //
    NSString *ident = [tableColumn identifier];
    if ([ident isEqualToString:@"check"]) {
        
        return [self tableView:tableView checkViewForObject:obj];
    }
    else if ([ident isEqualToString:@"name"]){
        
        return [self tableView:tableView nameViewForObject:obj];
    }
    else if ([ident isEqualToString:@"smartIndicator"]){
        
        return [self tableView:tableView indicatorViewForObject:obj];
    }
    
    return nil;
}

- (NSView *)tableView:(NSTableView *)tableView checkViewForObject:(MediaControllerObject *)obj{
    
    BSMediaStrategyEnableButton* result = [[BSMediaStrategyEnableButton alloc] initWithTableView:tableView];
    
    // make it a checkbox
    [result setButtonType:NSButtonTypeSwitch];
    //        result.refusesFirstResponder = YES;
    
    // check the user defaults
    
    NSNumber *enabled;
    if ([obj.representationObject isKindOfClass:[BSMediaStrategy class]]) {
        enabled = userStrategies[obj.name];
    }
    else{
        enabled = userNativeApps[obj.name];
    }
    if (!enabled || [enabled boolValue]) {
        [result setState:NSControlStateValueOn];
    } else {
        [result setState:NSControlStateValueOff];
    }
    
    //    [result setTitle:@""];
    [result setTarget:self];
    [result setAction:@selector(updateMediaStrategyRegistry:)];
    return result;
}

- (NSView *)tableView:(NSTableView *)tableView nameViewForObject:(MediaControllerObject *)obj{
    
    EHVerticalCenteredTextField *result = [EHVerticalCenteredTextField new];
    result.selectable = result.editable = result.drawsBackground = result.bordered = NO;
    
    NSMutableAttributedString *name = [[NSMutableAttributedString alloc]
                                       initWithString:obj.name
                                       attributes:@{
                                                    NSFontAttributeName :
                                                        [NSFont systemFontOfSize:[NSFont systemFontSize]]
                                                    }];
    if (![NSString isNullOrEmpty:obj.version]) {
        NSString *vString = [NSString
                             stringWithFormat:BSLocalizedString(@"  v.%@",
                                                                @"(GeneralPreferencesViewController) In preferences, strategies list."
                                                                @" Output format for name column "
                                                                @"of the strategy list."),
                             obj.version];
        NSAttributedString *version = [[NSAttributedString alloc]
                                       initWithString:vString
                                       attributes:@{
                                                    NSFontAttributeName :
                                                        [NSFont systemFontOfSize:[NSFont labelFontSize]],
                                                    NSForegroundColorAttributeName : [NSColor grayColor]
                                                    }];
        [name appendAttributedString:version];
    }
    result.attributedStringValue = name;
    
    if (obj.isCustom) {
        result.toolTip = _toolTipForCustomStrategy;
    }
    
    return result;
}

- (NSView *)tableView:(NSTableView *)tableView indicatorViewForObject:(MediaControllerObject *)obj{
    
    NSImageView* result = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    
    result.imageScaling = NSImageScaleNone;
    
    if (obj.isCustom){
        result.image = [NSImage imageNamed:@"custom"];
        result.toolTip = _toolTipForCustomStrategy;
    }
    
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    NSTableView *tableView = notification.object;
    
    if (tableView) {
        
        self.selectedRowAllowExport = self.selectedRowAllowRemove = NO;
        
        NSInteger index = [tableView selectedRow];
        if (index < 0) {
            return;
        }
        
        MediaControllerObject *obj = mediaControllerObjects[index];
        if ([obj.representationObject isKindOfClass:[BSMediaStrategy class]]) {
            
            self.selectedRowAllowExport = YES;
            if (obj.isCustom) {
                self.selectedRowAllowRemove = YES;
            }
        }
        
        [self.view.window recalculateKeyViewLoop];
    }
}

- (void)updateMediaStrategyRegistry:(id)sender {
    
    NSInteger index = [self.strategiesView rowForView:sender];
    if (index < 0) {
        return;
    }
    
    MediaControllerObject *obj = mediaControllerObjects[index];
    if (!obj || obj.isGroup) {
        return;
    }
    
    BOOL enabled;
    if ([sender state] == NSControlStateValueOn) {
        enabled = YES;
    } else {
        enabled = NO;
    }
    
    if ([obj.representationObject isKindOfClass:[BSMediaStrategy class]]) {
        // Strategy
        if (enabled) {
            [[MediaStrategyRegistry singleton] addAvailableMediaStrategy:obj.representationObject];
        } else {
            [[MediaStrategyRegistry singleton] removeAvailableMediaStrategy:obj.representationObject];
        }
        // save user strategies
        [userStrategies setObject:@(enabled) forKey:obj.name];
        [[NSUserDefaults standardUserDefaults]
         setObject:userStrategies
         forKey:BeardedSpiceActiveControllers];
    } else {
        // Native
        if (enabled) {
            [[NativeAppTabsRegistry singleton] enableNativeAppClass:obj.representationObject];
        } else {
            [[NativeAppTabsRegistry singleton] disableNativeAppClass:obj.representationObject];
        }
        // save user strategies
        [userNativeApps setObject:@(enabled) forKey:obj.name];
        [[NSUserDefaults standardUserDefaults]
         setObject:userNativeApps
         forKey:BeardedSpiceActiveNativeAppControllers];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:BSStrategiesPreferencesNativeAppChangedNoticiation
             object:self];
        });
    }
}

- (void)loadMediaControllerObjects{
    
    NSMutableArray *mediaControllers = [NSMutableArray array];
    
    NSArray *theArray = [NativeAppTabsRegistry defaultNativeAppClasses];
    if (theArray.count) {
        
        MediaControllerObject *obj = [MediaControllerObject new];
        obj.isGroup = YES;
        obj.name = BSLocalizedString(@"Native", @"General preferences - controllers table");
        [mediaControllers addObject:obj];
        for (Class theClass in theArray) {
            [mediaControllers addObject:[[MediaControllerObject alloc] initWithObject:theClass]];
        }
        
        userNativeApps = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:BeardedSpiceActiveNativeAppControllers]];
    }
    
    BSStrategyCache *cache = [[MediaStrategyRegistry singleton] strategyCache];
    theArray = [[cache allStrategies] sortedArrayUsingSelector:@selector(compare:)];
    if (theArray.count) {
        MediaControllerObject *obj = [MediaControllerObject new];
        obj.isGroup = YES;
        obj.name = BSLocalizedString(@"Web", @"General preferences - controllers table");
        [mediaControllers addObject:obj];
        for (BSMediaStrategy *strategy in theArray) {
            [mediaControllers addObject:[[MediaControllerObject alloc] initWithObject:strategy]];
        }
        userStrategies = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:BeardedSpiceActiveControllers]];
    }
    
    mediaControllerObjects = _mediaControllerObjectsCache = [mediaControllers copy];
}

- (void)applySearchField {
    if (self.searchField.stringValue.length) {
        NSPredicate *filter;
        if ([self.searchField.stringValue isEqualToString:@"custom"]) {
            filter = [NSPredicate predicateWithFormat:@"isCustom == YES"];
        }
        else {
            filter = [NSPredicate predicateWithFormat:@"isGroup == YES OR name contains[cd] %@", self.searchField.stringValue];
        }
        mediaControllerObjects = [_mediaControllerObjectsCache filteredArrayUsingPredicate:filter];
    }
    else {
        mediaControllerObjects = _mediaControllerObjectsCache;
    }
}

- (void)updateStrategiesView {
    [self loadMediaControllerObjects];
    [self applySearchField];
    [self.strategiesView reloadData];
}

- (void)strategyChangedNotify:(NSNotification*) notification{
    self.searchField.stringValue = @"";
    [self updateStrategiesView];
}

- (NSURL *)importExportDirectoryForCustomStrategy {
    
    NSURL *directoryURL;
    NSString *path = [[NSUserDefaults standardUserDefaults]
                      stringForKey:BeardedSpiceImportExportLastDirectory];
    if (path) {
        
        directoryURL = [NSURL URLWithString:path];
    } else {
        
        directoryURL =
        [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                               inDomain:NSLocalDomainMask
                                      appropriateForURL:nil
                                                 create:NO
                                                  error:nil];
        [[NSUserDefaults standardUserDefaults]
         setObject:[directoryURL path]
         forKey:BeardedSpiceImportExportLastDirectory];
    }
    
    return directoryURL;
}

- (BSMediaStrategy *)strategyFromTableSelection{
    
    NSInteger index = [self.strategiesView selectedRow];
    if (index < 0 || mediaControllerObjects.count <= index) {
        return nil;
    }
    
    MediaControllerObject *obj = mediaControllerObjects[index];
    if ([obj.representationObject isKindOfClass:[BSMediaStrategy class]]) {
        
        return obj.representationObject;
    }
    
    return nil;
}

- (void)importStrategyWithUrl:(NSURL *)fileURL {
    [APPDELEGATE setInUpdatingStrategiesState:YES];
    [[BSCustomStrategyManager singleton] importFromUrl:fileURL completion:^(BSMediaStrategy *strategy, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSAlert *alert = [NSAlert new];
                NSString *strategyName =
                [[fileURL lastPathComponent] stringByDeletingPathExtension];
                alert.alertStyle = NSAlertStyleCritical;
                alert.informativeText = error.localizedDescription;
                alert.messageText = [NSString
                                     stringWithFormat:BSLocalizedString(@"Can't import \"%@\" strategy.",
                                                                        @"(BSCustomStrategyManager) Title "
                                                                        @"on message, when strategy "
                                                                        @"import error occured."),
                                     strategyName];
                [alert addButtonWithTitle:BSLocalizedString(@"Ok", @"Ok button")];
                
                [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
                [APPDELEGATE setInUpdatingStrategiesState:NO];
            });
            return;
        }
        
        if (strategy) {
            self.searchField.stringValue = @"";
            [self updateStrategiesView];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSAlert *alert = [NSAlert new];
                NSString *strategyName =
                [strategy.fileName stringByDeletingPathExtension];
                alert.alertStyle = NSAlertStyleInformational;
                alert.informativeText = [strategy description];
                alert.messageText = [NSString
                                     stringWithFormat:
                                     BSLocalizedString(
                                                       @"Strategy \"%@\" imported successfuly.",
                                                       @"(BSCustomStrategyManager) Title on message, "
                                                       @"when strategy import error occured."),
                                     strategyName];
                [alert addButtonWithTitle:BSLocalizedString(@"Ok",
                                                            @"Ok button")];
                [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                    [self selectStrategy:strategy];
                    [APPDELEGATE setInUpdatingStrategiesState:NO];
                }];
            });
        }
    }];
}

- (void)selectStrategy:(BSMediaStrategy *)strategy {
    if (strategy == nil) {
        return;
    }
    
    MediaControllerObject *obj = [[MediaControllerObject alloc] initWithObject:strategy];
    NSUInteger index = [mediaControllerObjects indexOfObject:obj];
    if (index != NSNotFound) {
        [self.view.window makeFirstResponder:self.strategiesView];
        [self.strategiesView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [self.strategiesView scrollRowToVisible:index];
    }
}

@end
