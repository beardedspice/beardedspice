//
//  BSWebTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "TabAdapter.h"
#import "PSWebSocket.h"
@class BSTrack, PSWebSocket, BSMediaStrategy;

@interface BSWebTabAdapter : TabAdapter <PSWebSocketDelegate>

/// Creates instance if this class suitable for WebTab.
/// This method uses `suitableForSocket` for checking
/// @param tabSocket Socket of the Webtab
/// @return Retruns nil on error or if this class does not suit.
+ (instancetype)adapterForSocket:(PSWebSocket *)tabSocket;

/// Checks, that class of the instance suitable for WebTab
/// This method must be overwritten in child class
- (BOOL)suitableForSocket;

@property (nonatomic, readonly) PSWebSocket *tabSocket;
@property (nonatomic, readonly) BSMediaStrategy *strategy;

/// Sends message to web tab
/// @param message message an instance of NSData or NSString to send
- (id)sendMessage:(id)message;

/**
 Notifies controller through `receiver` (current tab) that global settings was changed.

 @return YES on success
 */
- (BOOL)notifyThatGlobalSettingsChanged;

@end
