//
//  BSActiveTab.h
//  BeardedSpice
//
//  Created by Alex Evers on 10/16/2016.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSActiveTab.h"
#import "NSString+Utils.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"
#import "runningSBApplication.h"

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
        [tabAdapter isKindOfClass:BSNativeAppTabAdapter.class])
        return [_activeTab isEqual:tabAdapter];

    return NO;
}

#pragma mark - accessors

- (NSString *)displayName {
    if ([self isNativeAdapter]) {
        return [_activeTab.class displayName];
    } else if ([self isWebAdapter]) {
        BSMediaStrategy *strategy = [(BSWebTabAdapter *)_activeTab strategy];
        return strategy.displayName;
    }
    return nil;
}

- (NSString *)title {
    if ([self isNativeAdapter]) {
        return [_activeTab.class displayName];
    } else if ([self isWebAdapter]){
        NSString *result;
        @try {
            result = _activeTab.title;
        } @catch (NSException *exception) {
            BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
        }
        if ([NSString isNullOrEmpty:result]) {
            result = ((BSWebTabAdapter *)_activeTab).strategy.displayName;
        }

        return result;
    }
    return BSLocalizedString(@"Unknown", @"Active tab title if we do not know type of the tab.");
}

- (BOOL)isNativeAdapter {
    return [_activeTab isKindOfClass:BSNativeAppTabAdapter.class];
}

- (BOOL)isWebAdapter {
    return [_activeTab isKindOfClass:BSWebTabAdapter.class];
}

- (BOOL)isTabAdapter {
    return [_activeTab isKindOfClass:TabAdapter.class] && ![self isNativeAdapter];
}

- (BOOL)respondsTo:(SEL)selector {
    return [_activeTab respondsToSelector:selector];
}

- (BOOL)isPlaying {
    @try {
        return [_activeTab isPlaying];
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
    return NO;
}

#pragma mark - mutators

- (BOOL)updateActiveTab:(TabAdapter *)tab {
    @try {
        BS_LOG(LOG_DEBUG, @"(AppDelegate - updateActiveTab) with tab %@", tab);
        
        if (![tab isEqual:_activeTab]) {
            BOOL needsActivated = NO;
            BS_LOG(LOG_DEBUG, @"(AppDelegate - updateActiveTab) tab %@ is different from %@", tab, _activeTab);
            if (_activeTab) {
                [self.activeTab pause];
                if ([self.activeTab frontmost]) {
                    needsActivated = YES;
                }
                if ([self.activeTab deactivateTab]) {
                    if (! [self.activeTab.application isEqual:tab.application]) {
                        [self.activeTab deactivateApp];
                    }
                }
            }
            
            self.activeTab = tab;
            if (needsActivated) {
                BS_LOG(LOG_DEBUG, @"Needs Activated %@", _activeTab);
                [self activateTab];
            }
            BS_LOG(LOG_DEBUG, @"Active tab set to %@", _activeTab);
        }
        return YES;
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
    return NO;
}

- (void)pauseActiveTab {
    @try {
        [_activeTab pause];
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
}

- (void)activateTab {
    @try {
        [_activeTab activateApp];
        [_activeTab activateTab];
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
}

- (void)activatePlayingTab {
    @try {
        [_activeTab toggleTab];
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
}

#pragma mark - core media operations
// TODO lots of repeat code here.

- (void)toggle {
    @try {
        if ([_activeTab toggle]
            && [_activeTab showNotifications]
            && alwaysShowNotification()
            && ![_activeTab frontmost]) {
            [self showNotification];
        }
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
}

- (void)next {
    __weak typeof(self) wself = self;
    @try {
        if ([_activeTab next]
            && [_activeTab showNotifications]
            && alwaysShowNotification()
            && ![_activeTab frontmost])
            dispatch_main_after(CHANGE_TRACK_DELAY, ^{ [wself showNotification]; });
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
}

- (void)previous {
    __weak typeof(self) wself = self;
    @try {
        if ([_activeTab previous]
            && [_activeTab showNotifications]
            && alwaysShowNotification()
            && ![_activeTab frontmost])
            dispatch_main_after(CHANGE_TRACK_DELAY, ^{ [wself showNotification]; });
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
}

- (void)favorite {
    __weak typeof(self) wself = self;
    @try {
        if ([_activeTab favorite]
            && [_activeTab showNotifications]
            && [[_activeTab trackInfo] favorited])
            dispatch_main_after(FAVORITED_DELAY, ^{ [wself showNotification]; });
    } @catch (NSException *exception) {
        BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
    }
}
    
#pragma mark - BSVolumeControlProtocol implementation

- (BSVolumeControlResult)volumeUp {
    return [self volume:@selector(volumeUp)];
}

- (BSVolumeControlResult)volumeDown {
    return [self volume:@selector(volumeDown)];
}

- (BSVolumeControlResult)volumeMute {
    return [self volume:@selector(volumeMute)];
}

- (BSVolumeControlResult)volume:(SEL)selector {

    BSVolumeControlResult result = BSVolumeControlNotSupported;
    
    if ([_activeTab conformsToProtocol:@protocol(BSVolumeControlProtocol)]) {
        NSMethodSignature *sig = [[_activeTab class] instanceMethodSignatureForSelector:selector];
        if (sig) {
            @try {
                if ([_activeTab isPlaying]) {
                    
                    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
                    [invocation setSelector:selector];
                    [invocation setTarget:_activeTab];
                    [invocation invoke];
                    [invocation getReturnValue:&result];
                }
            } @catch (NSException *exception) {
                BS_LOG(LOG_ERROR, @"(%s) Exception occured: %@", __FUNCTION__, exception);
            }
        }
    }
    
    return result;
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
            track = [(BSNativeAppTabAdapter *)_activeTab trackInfo];
        }
    } else {
        track = [_activeTab trackInfo];
    }

    BOOL noTrack = [NSString isNullOrEmpty:track.track];
    BOOL noArtist = [NSString isNullOrEmpty:track.artist];
    BOOL noAlbum = [NSString isNullOrEmpty:track.album];
    if (!(noTrack && noArtist && noAlbum)) {
        NSUserNotification *noti = [track asNotification];
        NSUserNotificationCenter *notifCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
        [notifCenter removeDeliveredNotification:noti];
        [notifCenter deliverNotification:noti];
        BS_LOG(LOG_DEBUG, @"Show Notification: %@", track);
    } else if (fallback) {
        [self showDefaultNotification];
    }
}

- (void)showDefaultNotification {
    NSUserNotification *notification = [NSUserNotification new];

    notification.identifier = kBSTrackNameIdentifier;
    notification.title = [self displayName];
    notification.informativeText = BSLocalizedString(@"no-track-title", @"No tack title for tabs menu and default notification ");

    NSUserNotificationCenter *notifCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notifCenter removeDeliveredNotification:notification];
    [notifCenter deliverNotification:notification];

    NSLog(@"Showing Default Notification");
}

@end
