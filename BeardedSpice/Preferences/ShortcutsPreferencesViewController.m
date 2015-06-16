//
//  AdvansedPreferencesViewController.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 13.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "ShortcutsPreferencesViewController.h"

NSString *const BeardedSpicePlayPauseShortcut = @"BeardedSpicePlayPauseShortcut";
NSString *const BeardedSpiceNextTrackShortcut = @"BeardedSpiceNextTrackShortcut";
NSString *const BeardedSpicePreviousTrackShortcut = @"BeardedSpicePreviousTrackShortcut";
NSString *const BeardedSpiceActiveTabShortcut = @"BeardedSpiceActiveTabShortcut";
NSString *const BeardedSpiceFavoriteShortcut = @"BeardedSpiceFavoriteShortcut";
NSString *const BeardedSpiceNotificationShortcut = @"BeardedSpiceNotificationShortcut";
NSString *const BeardedSpiceActivatePlayingTabShortcut = @"BeardedSpiceActivatePlayingTabShortcut";

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

@end
