//
//  GeneralPreferencesViewController.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/18/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GeneralPreferencesViewController.h"
#import "MediaControllerObject.h"
#import "BSLaunchAtLogin.h"
#import "BSMediaStrategyEnableButton.h"

NSString *const GeneralPreferencesNativeAppChangedNoticiation = @"GeneralPreferencesNativeAppChangedNoticiation";
NSString *const GeneralPreferencesAutoPauseChangedNoticiation = @"GeneralPreferencesAutoPauseChangedNoticiation";
NSString *const GeneralPreferencesUsingAppleRemoteChangedNoticiation = @"GeneralPreferencesUsingAppleRemoteChangedNoticiation";

NSString *const BeardedSpiceActiveControllers = @"BeardedSpiceActiveControllers";
NSString *const BeardedSpiceActiveNativeAppControllers = @"BeardedSpiceActiveNativeAppControllers";
NSString *const BeardedSpiceAlwaysShowNotification = @"BeardedSpiceAlwaysShowNotification";
NSString *const BeardedSpiceRemoveHeadphonesAutopause = @"BeardedSpiceRemoveHeadphonesAutopause";
NSString *const BeardedSpiceUsingAppleRemote = @"BeardedSpiceUsingAppleRemote";
NSString *const BeardedSpiceLaunchAtLogin = @"BeardedSpiceLaunchAtLogin";

@implementation GeneralPreferencesViewController

- (id)initWithMediaStrategyRegistry:(MediaStrategyRegistry *)mediaStrategyRegistry nativeAppTabRegistry:(NativeAppTabRegistry *)nativeAppTabRegistry
{
    self = [super initWithNibName:@"GeneralPreferencesView" bundle:nil];
    if (self) {
        
        NSMutableArray *mediaControllers = [NSMutableArray array];
        
        NSArray *theArray = [NativeAppTabRegistry defaultNativeAppClasses];
        if (theArray.count) {
            
            MediaControllerObject *obj = [MediaControllerObject new];
            obj.isGroup = YES;
            obj.name = NSLocalizedString(@"Native", @"General preferences - controllers table");
            [mediaControllers addObject:obj];
            for (Class theClass in theArray) {
                [mediaControllers addObject:[[MediaControllerObject alloc] initWithObject:theClass]];
            }
            
            userNativeApps = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:BeardedSpiceActiveNativeAppControllers]];
        }
        
        theArray = [MediaStrategyRegistry getDefaultMediaStrategies];
        if (theArray.count) {
            MediaControllerObject *obj = [MediaControllerObject new];
            obj.isGroup = YES;
            obj.name = NSLocalizedString(@"Web", @"General preferences - controllers table");
            [mediaControllers addObject:obj];
            for (MediaStrategy *strategy in theArray) {
                [mediaControllers addObject:[[MediaControllerObject alloc] initWithObject:strategy]];
            }
            userStrategies = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:BeardedSpiceActiveControllers]];
        }
        strategyRegistry = mediaStrategyRegistry;
        nativeRegistry = nativeAppTabRegistry;
        mediaControllerObjects = [mediaControllers copy];
    }
    return self;
}

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (void)viewWillAppear{
    
    [self repairLaunchAtLogin];
}

- (NSView *)initialKeyView{

    return self.firstResponderView;
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Actions
/////////////////////////////////////////////////////////////////////////

- (IBAction)toggleLaunchAtStartup:(id)sender{

    BOOL shouldBeLaunchAtLogin = [[NSUserDefaults standardUserDefaults] boolForKey:BeardedSpiceLaunchAtLogin];
    [BSLaunchAtLogin launchAtStartup:shouldBeLaunchAtLogin];

}

- (IBAction)toggleAutoPause:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:GeneralPreferencesAutoPauseChangedNoticiation
         object:self];
    });

}

- (IBAction)toggleUseRemote:(id)sender {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:GeneralPreferencesUsingAppleRemoteChangedNoticiation
         object:self];
    });
}


/////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
/////////////////////////////////////////////////////////////////////////

// Repairs user defaults from login items.
- (void)repairLaunchAtLogin{
    
    [[NSUserDefaults standardUserDefaults] setBool:[BSLaunchAtLogin isLaunchAtStartup] forKey:BeardedSpiceLaunchAtLogin];
}

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
            result.alignment = NSCenterTextAlignment;
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
    if ([[tableColumn identifier] isEqualToString:@"strategy"]) {
        
        return [self tableView:tableView strategyViewForObject:obj];
    }
    else{
        
        return [self tableView:tableView indicatorViewForObject:obj];
    }
}

- (NSView *)tableView:(NSTableView *)tableView strategyViewForObject:(MediaControllerObject *)obj{
    
    NSButton *result = [tableView makeViewWithIdentifier:@"AvailbleStrategiesView" owner:self];
    
    // there is no existing cell to reuse so create a new one
    if (result == nil) {
        result = [[BSMediaStrategyEnableButton alloc] initWithTableView:tableView];
        
        // this allows the cell to be reused.
        result.identifier = @"AvailbleStrategiesView";
        
        // make it a checkbox
        [result setButtonType:NSSwitchButton];
//        result.refusesFirstResponder = YES;
        
    }
    
    
    // check the user defaults
    
    NSNumber *enabled;
    if ([obj.representationObject isKindOfClass:[MediaStrategy class]]) {
        enabled = userStrategies[obj.name];
    }
    else{
        enabled = userNativeApps[obj.name];
    }
    if (!enabled || [enabled boolValue]) {
        [result setState:NSOnState];
    } else {
        [result setState:NSOffState];
    }
    
    [result setTitle:obj.name];
    [result setTarget:self];
    [result setAction:@selector(updateMediaStrategyRegistry:)];
    return result;
}

- (NSView *)tableView:(NSTableView *)tableView indicatorViewForObject:(MediaControllerObject *)obj{
    
    NSImageView *result = [tableView makeViewWithIdentifier:@"StrategyView" owner:self];
    
    // there is no existing cell to reuse so create a new one
    if (result == nil) {
        result = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 21, 21)];
        
        result.imageScaling = NSImageScaleNone;
        result.identifier = @"StrategyView";
        
    }
    if (obj.isAuto)
        result.image = [NSImage imageNamed:@"auto"];
    
    return result;
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
    if ([sender state] == NSOnState) {
        enabled = YES;
    } else {
        enabled = NO;
    }

    if ([obj.representationObject isKindOfClass:[MediaStrategy class]]) {
        // Strategy
        if (enabled) {
            [strategyRegistry addMediaStrategy:obj.representationObject];
        } else {
            [strategyRegistry removeMediaStrategy:obj.representationObject];
        }
        // save user strategies
        [userStrategies setObject:@(enabled) forKey:obj.name];
        [[NSUserDefaults standardUserDefaults]
            setObject:userStrategies
               forKey:BeardedSpiceActiveControllers];
    } else {
        // Native
        if (enabled) {
            [nativeRegistry enableNativeAppClass:obj.representationObject];
        } else {
            [nativeRegistry disableNativeAppClass:obj.representationObject];
        }
        // save user strategies
        [userNativeApps setObject:@(enabled) forKey:obj.name];
        [[NSUserDefaults standardUserDefaults]
            setObject:userNativeApps
               forKey:BeardedSpiceActiveNativeAppControllers];

        dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter]
              postNotificationName:GeneralPreferencesNativeAppChangedNoticiation
                            object:self];
        });
    }
}

@end
