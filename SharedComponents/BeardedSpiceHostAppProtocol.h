//
//  BeardedSpiceHostAppProtocol.h
//  BeardedSpiceControllers
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>

@protocol BeardedSpiceHostAppProtocol

- (void)playPauseToggle;
- (void)nextTrack;
- (void)previousTrack;

- (void)activeTab;
- (void)favorite;
- (void)notification;
- (void)activatePlayingTab;

- (void)playerNext;
- (void)playerPrevious;

- (void)volumeUp;
- (void)volumeDown;
- (void)volumeMute;

- (void)headphoneUnplug;

@end
