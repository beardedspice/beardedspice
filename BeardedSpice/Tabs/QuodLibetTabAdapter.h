//
//  QuodLibetTabAdapter.h
//  BeardedSpice
//
//  Created by Martijn Pieters on 13/02/2021.
//  Copyright (c) 2021 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "NativeAppTabAdapter.h"

/** Possible QuodLibet player states. */
enum QuodLibetStatus {
    QuodLibetStatusUnknown,
    QuodLibetStatusPaused,
    QuodLibetStatusPlaying,
};
typedef enum QuodLibetStatus QuodLibetStatus;

@interface QuodLibetTabAdapter : NativeAppTabAdapter

@end
