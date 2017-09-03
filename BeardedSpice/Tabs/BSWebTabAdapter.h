//
//  BSWebTabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 19.08.17.
//  Copyright © 2017 BeardedSpice. All rights reserved.
//

#import "TabAdapter.h"

@class BSTrack, PSWebSocket;

@interface BSWebTabAdapter : TabAdapter

- (id)initWithBrowserSocket:(PSWebSocket *)browserSocket;

@property (nonatomic, readonly) PSWebSocket *browserSocket;

- (void)toggle;
- (void)pause;
- (void)next;
- (void)previous;
- (void)favorite;

- (BSTrack *)trackInfo;
- (BOOL)isPlaying;

@end
