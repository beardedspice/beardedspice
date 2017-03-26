//
//  BSActiveTab.h
//  BeardedSpice
//
//  Created by Alex Evers on 10/16/2016.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSActiveTab.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"

// Create serial queue for notification
// We need queue because track info may contain image,
// which retrieved from URL, this may cause blocking of the main thread.
dispatch_queue_t notificationQueue() {
    static dispatch_queue_t notifQueue;
    static dispatch_once_t setupQueue;
    dispatch_once(&setupQueue, ^{
        notifQueue = dispatch_queue_create("com.beardedspice.notification.serial", DISPATCH_QUEUE_SERIAL);
    });

    return notifQueue;
}

@implementation BSActiveTab

#pragma mark - NSObject overrides

- (instancetype)init {
    self = [super init];
    if (self) {
        _registry = [MediaStrategyRegistry singleton];
    }
    return self;
}

- (BOOL)hasEqualTabAdapter:(id)tabAdapter {
    if ([tabAdapter isKindOfClass:TabAdapter.class] ||
        [tabAdapter isKindOfClass:NativeAppTabAdapter.class])
        return [_activeTab isEqual:tabAdapter];

    return NO;
}

#pragma mark - accessors

- (NSString *)displayName {
    if ([self isNativeAdapter]) {
        return [_activeTab.class displayName];
    } else {
        BSMediaStrategy *strategy = [_registry getMediaStrategyForTab:_activeTab];
        return strategy.displayName;
    }
}

- (NSString *)title {
    if ([self isNativeAdapter]) {
        return [_activeTab.class displayName];
    } else {
        return _activeTab.title;
    }
}

- (BOOL)isNativeAdapter {
    return [_activeTab isKindOfClass:NativeAppTabAdapter.class];
}

- (BOOL)isTabAdapter {
    return [_activeTab isKindOfClass:TabAdapter.class] && ![self isNativeAdapter];
}

- (BOOL)respondsTo:(SEL)selector {
    return [_activeTab respondsToSelector:selector];
}

#pragma mark - mutators

- (BOOL)updateActiveTab:(TabAdapter *)tab {
    BS_LOG(LOG_DEBUG, @"(AppDelegate - updateActiveTab) with tab %@", tab);

    // Prevent switch to tab, which not have strategy.
    BSMediaStrategy *strategy = nil;
    if (![tab isKindOfClass:[NativeAppTabAdapter class]]) {

        BS_LOG(LOG_DEBUG, @"(AppDelegate - updateActiveTab) tab %@ check strategy", tab);
        strategy = [_registry getMediaStrategyForTab:tab];
        if (!strategy) {
            return NO;
        }
    }

    BS_LOG(LOG_DEBUG, @"(AppDelegate - updateActiveTab) tab %@ has strategy", tab);

    if (![tab isEqual:_activeTab]) {
        BS_LOG(LOG_DEBUG, @"(AppDelegate - updateActiveTab) tab %@ is different from %@", tab, _activeTab);
        if (_activeTab) {
            [self pauseActiveTab];
            if ([self.activeTab isActivated]) {
                [self.activeTab toggleTab];
            }
        }

        self.activeTab = tab;
        self.activeTabKey = [tab key];
        BS_LOG(LOG_DEBUG, @"Active tab set to %@", _activeTab);
    }
    return YES;
}

- (void)clearActiveTab {
    //[_activeTab pause]; // FIXME do we need this?
    self.activeTab = nil;
    self.activeTabKey = nil;
}

- (void)repairActiveTab:(TabAdapter *)tab {
    if ([_activeTabKey isEqualToString:[tab key]]) {
        self.activeTab = [tab copyStateFrom:_activeTab];
    }
}

- (void)pauseActiveTab {
    if ([self isNativeAdapter]) {
        if ([_activeTab respondsToSelector:@selector(pause)])
            [(NativeAppTabAdapter *)_activeTab pause];
    } else {
        BSMediaStrategy *strategy = [_registry getMediaStrategyForTab:_activeTab];
        if (strategy) {
            [_activeTab executeJavascript:[strategy pause]];
        }
    }

}

- (void)activateTab {
    [_activeTab activateTab];
}

- (void)activatePlayingTab {
    [_activeTab toggleTab];
}

#pragma mark - core media operations
// TODO lots of repeat code here.

- (void)toggle {
    if ([self isNativeAdapter]) {
        NativeAppTabAdapter *tab = (NativeAppTabAdapter *)_activeTab;
        if ([tab respondsToSelector:@selector(toggle)]) {
            [tab toggle];
            if ([tab showNotifications] && alwaysShowNotification() && ![tab frontmost])
                [self showNotification];
        }
    } else {
        BSMediaStrategy *strategy = [_registry getMediaStrategyForTab:_activeTab];
        if (strategy && ![NSString isNullOrEmpty:[strategy toggle]]) {
            [_activeTab executeJavascript:[strategy toggle]];
            if (alwaysShowNotification() && ![_activeTab frontmost]) {
                [self showNotification];
            }
        }
    }
}

- (void)next {
    __weak typeof(self) wself = self;
    if ([self isNativeAdapter]) {
        NativeAppTabAdapter *tab = (NativeAppTabAdapter *)_activeTab;
        if ([tab respondsToSelector:@selector(next)]) {
            [tab next];
            if ([tab showNotifications] && alwaysShowNotification() && ![tab frontmost])
                dispatch_main_after(FAVORITED_DELAY, ^{ [wself showNotification]; });
        }
    } else {
        BSMediaStrategy *strategy =[_registry getMediaStrategyForTab:_activeTab];
        if (strategy && ![NSString isNullOrEmpty:[strategy next]]) {
            [_activeTab executeJavascript:[strategy next]];
            if (alwaysShowNotification() && ![_activeTab frontmost])
                dispatch_main_after(FAVORITED_DELAY, ^{ [wself showNotification]; });
        }
    }
}

- (void)previous {
    __weak typeof(self) wself = self;
    if ([self isNativeAdapter]) {
        NativeAppTabAdapter *tab = (NativeAppTabAdapter *)_activeTab;
        if ([tab respondsToSelector:@selector(previous)]) {
            [tab previous];
            if ([tab showNotifications] && alwaysShowNotification() && ![tab frontmost])
                dispatch_main_after(CHANGE_TRACK_DELAY, ^{ [wself showNotification]; });
        }
    } else {
        BSMediaStrategy *strategy = [_registry getMediaStrategyForTab:_activeTab];
        if (strategy && ![NSString isNullOrEmpty:[strategy previous]]) {
            [_activeTab executeJavascript:[strategy previous]];
            if (alwaysShowNotification() && ![_activeTab frontmost])
                dispatch_main_after(CHANGE_TRACK_DELAY, ^{ [wself showNotification]; });
        }
    }
}

- (void)favorite {
    __weak typeof(self) wself = self;
    if ([self isNativeAdapter]) {
        NativeAppTabAdapter *tab = (NativeAppTabAdapter *)_activeTab;
        if ([tab respondsToSelector:@selector(favorite)]) {
            [tab favorite];
            if ([[tab trackInfo] favorited])
                [self showNotification];
        }
    } else {
        BSMediaStrategy *strategy = [_registry getMediaStrategyForTab:_activeTab];
        if (strategy) {
            [_activeTab executeJavascript:[strategy favorite]];
            if ([[strategy trackInfo:_activeTab] favorited])
                dispatch_main_after(FAVORITED_DELAY, ^{ [wself showNotification]; });
        }
    }
}

#pragma mark - Notification logic

- (void)showNotification {
    [self showNotificationUsingFallback:NO];
}

- (void)showNotificationUsingFallback:(BOOL)useFallback {

    __weak typeof(self) wself = self;
    dispatch_async(notificationQueue(), ^{
        __strong typeof(wself) sself = self;
        @autoreleasepool {
            @try {
                [sself _showNotificationUsingFallback:useFallback];
            } @catch (NSException *exception) {
                BS_LOG(LOG_DEBUG, @"(AppDelegate - showNotificationUsingFallback) Error showing notification: %@.", [exception description]);
            }
        }
    });
}
- (void)_showNotificationUsingFallback:(BOOL)fallback {

    BSTrack *track = nil;
    if ([self isNativeAdapter]) {
        if ([_activeTab respondsToSelector:@selector(trackInfo)]) {
            track = [(NativeAppTabAdapter *)_activeTab trackInfo];
        }
    } else {
        BSMediaStrategy *strategy = [_registry getMediaStrategyForTab:_activeTab];
        if (strategy)
            track = [strategy trackInfo:_activeTab];
    }

    BOOL hasTrack = [NSString isNullOrEmpty:track.track];
    BOOL hasArtist = [NSString isNullOrEmpty:track.artist];
    BOOL hasAlbum = [NSString isNullOrEmpty:track.album];
    if (!(hasTrack && hasArtist && hasAlbum)) {
        // Remove previous notification.
        [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:[track asNotification]];
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:[track asNotification]];
        BS_LOG(LOG_DEBUG, @"Show Notification: %@", track);
    } else if (fallback) {
        [self showDefaultNotification];
    }
}

- (void)showDefaultNotification {
    NSUserNotification *notification = [NSUserNotification new];

    notification.title = [self displayName];
    notification.informativeText = @"No track info available";

    NSUserNotificationCenter *notifCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notifCenter deliverNotification:notification];

    NSLog(@"Showing Default Notification");
}

@end
