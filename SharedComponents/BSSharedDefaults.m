//
//  BSSharedDefaults.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSSharedDefaults.h"

NSString *const BeardedSpicePlayPauseShortcut = @"BeardedSpicePlayPauseShortcut";
NSString *const BeardedSpiceNextTrackShortcut = @"BeardedSpiceNextTrackShortcut";
NSString *const BeardedSpicePreviousTrackShortcut = @"BeardedSpicePreviousTrackShortcut";
NSString *const BeardedSpiceActiveTabShortcut = @"BeardedSpiceActiveTabShortcut";
NSString *const BeardedSpiceFavoriteShortcut = @"BeardedSpiceFavoriteShortcut";
NSString *const BeardedSpiceNotificationShortcut = @"BeardedSpiceNotificationShortcut";
NSString *const BeardedSpiceActivatePlayingTabShortcut = @"BeardedSpiceActivatePlayingTabShortcut";
NSString *const BeardedSpicePlayerNextShortcut = @"BeardedSpicePlayerNextShortcut";
NSString *const BeardedSpicePlayerPreviousShortcut = @"BeardedSpicePlayerPreviousShortcut";

NSString *const BSWebSocketServerPort = @"BSWebSocketServerPort";
NSString *const BSWebSocketServerStrategyAcceptors = @"BSWebSocketServerStrategyAcceptors";

NSString *const BSWebSocketServerStartedNotification = @"BSWebSocketServerStartedNotification";

@implementation BSSharedDefaults

static NSUserDefaults *_sharedUserDefaults;

+ (void)initialize{
    
    if (self == [BSSharedDefaults class]) {
        
        _sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:BS_APP_GROUP];
    }
}

+ (NSUserDefaults *)defaults{
    
    return _sharedUserDefaults;
}

+ (void)synchronizeDefaults{
    
    [_sharedUserDefaults synchronize];
}

@end
