//
//  BSActiveTab.h
//  BeardedSpice
//
//  Created by Alex Evers on 10/16/2016.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "TabAdapter.h"
#import "NativeAppTabAdapter.h"
#import "BSWebTabAdapter.h"
#import "MediaStrategyRegistry.h"
#import "BSVolumeControlProtocol.h"

/// Delay displaying notification after changing favorited status of the current track.
#define FAVORITED_DELAY         1.0

/// Delay displaying notification after pressing next/previous track.
#define CHANGE_TRACK_DELAY      2.0

typedef void (^BSVoidBlock)(void);

// underscores because c code
static inline void dispatch_main_after(int64_t time, BSVoidBlock block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

// camel case because objc code
// Because user defaults have good caching mechanism, we can use this macro.
static inline BOOL alwaysShowNotification() {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"BeardedSpiceAlwaysShowNotification"/*FIXME*/] boolValue];
}

@interface BSActiveTab : NSObject <BSVolumeControlProtocol>

@property (nonatomic, strong) NSDate *lastActive;
@property (nonatomic, strong) TabAdapter *activeTab;
@property (nonatomic, weak) MediaStrategyRegistry *registry;

- (BOOL)updateActiveTab:(TabAdapter *)tab;
- (void)clearActiveTab;
- (void)repairActiveTab:(TabAdapter *)tab;
- (void)pauseActiveTab;

#pragma mark -

- (NSString *)displayName;
- (NSString *)title;

/**  */
- (void)toggle;
- (void)next;
- (void)previous;
- (void)favorite;

- (void)showNotification;
- (void)showNotificationUsingFallback:(BOOL)useFallback;
- (void)showDefaultNotification;

- (void)activateTab;
- (void)activatePlayingTab;

#pragma mark -

- (BOOL)hasEqualTabAdapter:(id)tabAdapter;
- (BOOL)isNativeAdapter;
- (BOOL)isTabAdapter;
- (BOOL)respondsTo:(SEL)selector;

- (BOOL)isPlaying;

@end
