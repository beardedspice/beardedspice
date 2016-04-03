//
//  AdvansedPreferencesViewController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 13.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ShortcutsPreferencesViewController.h"
#import "BSSharedDefaults.h"

@implementation ShortcutsPreferencesViewController

- (id)init
{
    self = [super initWithNibName:@"ShortcutsPreferencesView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    // associate view with userdefaults
    [self.playPauseShortcut setAssociatedUserDefaultsKey:BeardedSpicePlayPauseShortcut];
    [self.nextTrackShortcut setAssociatedUserDefaultsKey:BeardedSpiceNextTrackShortcut];
    [self.previousTrackShortcut setAssociatedUserDefaultsKey:BeardedSpicePreviousTrackShortcut];
    [self.setActiveTabShortcut setAssociatedUserDefaultsKey:BeardedSpiceActiveTabShortcut];
    [self.favoriteShortcut setAssociatedUserDefaultsKey:BeardedSpiceFavoriteShortcut];
    [self.notificationShortcut setAssociatedUserDefaultsKey:BeardedSpiceNotificationShortcut];
    [self.activatePlayingTabShortcut setAssociatedUserDefaultsKey:BeardedSpiceActivatePlayingTabShortcut];
    [self.playerNextShortcut setAssociatedUserDefaultsKey:BeardedSpicePlayerNextShortcut];
    [self.playerPreviousShortcut setAssociatedUserDefaultsKey:BeardedSpicePlayerPreviousShortcut];
}

- (NSString *)identifier
{
    return @"ShortcutsPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"toolbarShortcuts"];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Shortcuts", @"Toolbar item name for the Shortcuts preference pane");
}

- (NSView *)initialKeyView{
    
    return self.playPauseShortcut;
}


@end
