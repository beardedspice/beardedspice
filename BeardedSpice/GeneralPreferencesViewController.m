//
//  GeneralPreferencesViewController.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/18/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

NSString *const BeardedSpiceActiveTabShortcut = @"BeardedSpiceActiveTabShortcut";
NSString *const BeardedSpiceFavoriteShortcut = @"BeardedSpiceFavoriteShortcut";
NSString *const BeardedSpiceNotificationShortcut = @"BeardedSpiceNotificationShortcut";
NSString *const BeardedSpiceActiveControllers = @"BeardedSpiceActiveControllers";
NSString *const BeardedSpiceAlwaysShowNotification = @"BeardedSpiceAlwaysShowNotification";

@implementation GeneralPreferencesViewController

- (id)initWithMediaStrategyRegistry:(MediaStrategyRegistry *)mediaStrategyRegistry
{
    self = [super initWithNibName:@"GeneralPreferencesView" bundle:nil];
    if (self) {
        availableStrategies = [MediaStrategyRegistry getDefaultMediaStrategies];
        userStrategies = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:BeardedSpiceActiveControllers]];
        registry = mediaStrategyRegistry;
    }
    return self;
}

- (void)awakeFromNib
{
    // associate view with userdefaults
    [self.setActiveTabShortcut setAssociatedUserDefaultsKey:BeardedSpiceActiveTabShortcut];
    [self.favoriteShortcut setAssociatedUserDefaultsKey:BeardedSpiceFavoriteShortcut];
    [self.notificationShortcut setAssociatedUserDefaultsKey:BeardedSpiceNotificationShortcut];
    // check the user defaults
    NSNumber *enabled = [[NSUserDefaults standardUserDefaults] objectForKey:BeardedSpiceAlwaysShowNotification];
    if ([enabled intValue] == 1) {
        [self.alwaysShowNotification setState:NSOnState];
    } else {
        [self.alwaysShowNotification setState:NSOffState];
    }
    [self.alwaysShowNotification setAction:@selector(updateNotificationPreferences:)];

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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return availableStrategies.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {

    MediaStrategy *strategy = [availableStrategies objectAtIndex:row];
    NSButton *result = [tableView makeViewWithIdentifier:@"AvailbleStrategiesView" owner:self];

    // there is no existing cell to reuse so create a new one
    if (result == nil) {
        result = [[NSButton alloc] init];

        // this allows the cell to be reused.
        result.identifier = @"AvailbleStrategiesView";

        // make it a checkbox
        [result setButtonType:NSSwitchButton];

        // just so we know the index of this cell
        [result setTag:row];

        // check the user defaults
        NSNumber *enabled = [userStrategies objectForKey:[strategy displayName]];
        if ([enabled intValue] == 1) {
            [result setState:NSOnState];
        } else {
            [result setState:NSOffState];
        }
    }

    [result setTitle:[strategy displayName]];
    [result setTarget:self];
    [result setAction:@selector(updateMediaStrategyRegistry:)];
    return result;
}

-(void)updateNotificationPreferences:(id)sender
{
    BOOL enabled;
    if ([self.alwaysShowNotification state] == NSOnState) {
        enabled = YES;
    } else {
        enabled = NO;
    }

    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:enabled] forKey:BeardedSpiceAlwaysShowNotification];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BeardedSpiceUpdatePreferences" object:self];
}

-(void)updateMediaStrategyRegistry:(id)sender
{
    MediaStrategy *strategy = [availableStrategies objectAtIndex:[sender tag]];
    BOOL enabled;
    if ([sender state] == NSOnState) {
        [registry addMediaStrategy:strategy];
        enabled = YES;
    } else {
        [registry removeMediaStrategy:strategy];
        enabled = NO;
    }

    // save user strategies
    [userStrategies setObject:[NSNumber numberWithBool:enabled] forKey:[strategy displayName]];
    [[NSUserDefaults standardUserDefaults] setObject:userStrategies forKey:BeardedSpiceActiveControllers];
}


@end
