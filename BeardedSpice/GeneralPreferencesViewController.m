//
//  GeneralPreferencesViewController.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/18/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

NSString *const BeardedSpiceActiveTabShortcut = @"BeardedSpiceActiveTabShortcut";

@implementation GeneralPreferencesViewController

- (id)init
{
    self = [super initWithNibName:@"GeneralPreferencesView" bundle:nil];
    if (self) {
        //
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

@end
