//
//  GeneralPreferencesViewController.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/18/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

NSString *const BeardedSpiceActiveTabShortcut = @"BeardedSpiceActiveTabShortcut";
NSString *const BeardedSpiceActiveControllers = @"BeardedSpiceActiveControllers";

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
    [self.shortcutView setAssociatedUserDefaultsKey:BeardedSpiceActiveTabShortcut];
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
