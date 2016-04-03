//
//  AdvansedPreferencesViewController.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 13.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "Shortcut.h"

@interface ShortcutsPreferencesViewController : NSViewController <MASPreferencesViewController>

@property (nonatomic, weak) IBOutlet MASShortcutView *playPauseShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *nextTrackShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *previousTrackShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *activatePlayingTabShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *setActiveTabShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *favoriteShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *notificationShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *playerNextShortcut;
@property (nonatomic, weak) IBOutlet MASShortcutView *playerPreviousShortcut;

@end
