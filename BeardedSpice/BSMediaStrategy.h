//
//  BSMediaStrategy.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@class BSTrack;
@class TabAdapter;

extern NSString * _Nonnull const kBSMediaStrategyKeyVersion;
extern NSString * _Nonnull const kBSMediaStrategyKeyDisplayName;

extern NSString * _Nonnull const kBSMediaStrategyKeyAcceptsMethod;
extern NSString * _Nonnull const kBSMediaStrategyKeyAcceptsParams;
extern NSString * _Nonnull const kBSMediaStrategyKeyIsPlaying;
extern NSString * _Nonnull const kBSMediaStrategyKeyToggle;
extern NSString * _Nonnull const kBSMediaStrategyKeyPrevious;
extern NSString * _Nonnull const kBSMediaStrategyKeyNext;
extern NSString * _Nonnull const kBSMediaStrategyKeyFavorite;
extern NSString * _Nonnull const kBSMediaStrategyKeyPause;
extern NSString * _Nonnull const kBSMediaStrategyKeyTrackInfo;

extern NSString * _Nonnull const kBSMediaStrategyAcceptPredicateOnTab;
extern NSString * _Nonnull const kBSMediaStrategyAcceptScript;
extern NSString * _Nonnull const kBSMediaStrategyAcceptKeyFormat;
extern NSString * _Nonnull const kBSMediaStrategyAcceptKeyArgs;
extern NSString * _Nonnull const kBSMediaStrategyAcceptValueURL;
extern NSString * _Nonnull const kBSMediaStrategyAcceptValueTitle;

@interface BSMediaStrategy : NSObject

@property (nonatomic, strong, readonly) NSString * _Nonnull fileName;
@property (nonatomic, assign, readonly) long strategyVersion;

// This data should only be used for tests. DO NOT directly access.
@property (nonatomic, strong, readonly) JSValue * _Nullable strategyData;

/**
 Caches the loaded strategies for reuse and requerying without hitting the disk.
 @param strategyName the name of the strategy file to be accessed. Case Sensitive.
 @param reloadData YES to refresh the cache entry from file. NO to go straight to cache unless it's a miss.
 @returns a dictionary with the most recently loaded copy of the specified strategy
 */
+ (BSMediaStrategy * _Nullable)cacheForStrategyName:(NSString * _Nonnull)strategyName;

/**
 A method for reloading the strategy plist from file, updating all future uses of this
 object to be with the most up-to-date plan of attack.
 */
- (void)reloadData;

/**
    @param strategyName
    @return Returns a BSMediaStrategy object with data loaded from the provided plist.
        The loaded flag is set to determine if the file existed or not.
 */
- (instancetype _Nonnull)initWithStrategyName:(NSString * _Nonnull)strategyName;

/**
    @return Returns name of that media stratery.
 */
-(NSString * _Nonnull)displayName; // Required override in subclass.

/**
    @return A Boolean saying if this is a tab that accepts this strategy.
 */
-(BOOL)accepts:(TabAdapter * _Nonnull)tab; // Required override in subclass.


/**
    @param methodName the name of the method to check if is implemented by this strategy
    @return A Boolean indicating if this strategy has implemented the provided method name
 */
- (BOOL)testIfImplemented:(NSString * _Nonnull)methodName;

/**
    @return A Boolean saying if this tab is in the playback state.
 */
- (BOOL)isPlaying:(TabAdapter * _Nonnull)tab;

/**
    @return Returns track information object from tab.
 */
- (BSTrack * _Nullable)trackInfo:(TabAdapter * _Nonnull)tab;


// Methods, which return javascript code for apropriated actions.
//---------------------------------------------------------------

/**
    @return Returns javascript code of the play/pause toggle.
 */
-(NSString * _Nonnull)toggle; // Required override in subclass.

/**
    @return Returns javascript code of the previous track action.
 */
-(NSString * _Nonnull)previous;

/**
    @return Returns javascript code of the next track action.
 */
-(NSString * _Nonnull)next;

/**
    @return Returns javascript code of the pausing action. Used mainly for pausing before switching active tabs.
 */
-(NSString * _Nonnull)pause; // Required override in subclass.

/**
    @return Returns javascript code of the "favorite" toggle.
 */
-(NSString * _Nonnull)favorite;

@end
