//
//  BSWebTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "TabAdapter.h"
#import <PSWebSocket.h>
@class BSTrack, PSWebSocket, BSMediaStrategy;

@interface BSWebTabAdapter : TabAdapter <PSWebSocketDelegate>

- (id)initWithBrowserSocket:(PSWebSocket *)tabSocket;

@property (nonatomic, readonly) PSWebSocket *tabSocket;
@property (nonatomic, readonly) BSMediaStrategy *strategy;

@end
