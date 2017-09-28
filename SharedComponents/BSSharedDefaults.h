//
//  BSSharedDefaults.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>

extern NSString *const BeardedSpicePlayPauseShortcut;
extern NSString *const BeardedSpiceNextTrackShortcut;
extern NSString *const BeardedSpicePreviousTrackShortcut;
extern NSString *const BeardedSpiceActiveTabShortcut;
extern NSString *const BeardedSpiceFavoriteShortcut;
extern NSString *const BeardedSpiceNotificationShortcut;
extern NSString *const BeardedSpiceActivatePlayingTabShortcut;
extern NSString *const BeardedSpicePlayerNextShortcut;
extern NSString *const BeardedSpicePlayerPreviousShortcut;

extern NSString *const BSWebSocketServerPort;
extern NSString *const BSWebSocketServerStrategyAcceptors;

extern NSString *const BSWebSocketServerStartedNotification;

@interface BSSharedDefaults : NSObject

/**
 Returns shared user defaults object.
 */
+ (NSUserDefaults *)defaults;

/**
 Performs flush of the shared user defaults.
 */
+ (void)synchronizeDefaults;


@end
