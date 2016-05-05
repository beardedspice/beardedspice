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

extern NSString *const kBSMediaStrategyKeyVersion;
extern NSString *const kBSMediaStrategyKeyDisplayName;

extern NSString *const kBSMediaStrategyKeyAcceptsMethod;
extern NSString *const kBSMediaStrategyKeyAcceptsParams;
extern NSString *const kBSMediaStrategyKeyIsPlaying;
extern NSString *const kBSMediaStrategyKeyToggle;
extern NSString *const kBSMediaStrategyKeyPrevious;
extern NSString *const kBSMediaStrategyKeyNext;
extern NSString *const kBSMediaStrategyKeyFavorite;
extern NSString *const kBSMediaStrategyKeyPause;
extern NSString *const kBSMediaStrategyKeyTrackInfo;

extern NSString *const kBSMediaStrategyAcceptPredicateOnTab;
extern NSString *const kBSMediaStrategyAcceptScript;
extern NSString *const kBSMediaStrategyAcceptKeyFormat;
extern NSString *const kBSMediaStrategyAcceptKeyArgs;
extern NSString *const kBSMediaStrategyAcceptValueURL;
extern NSString *const kBSMediaStrategyAcceptValueTitle;

@interface BSMediaStrategy : NSObject

@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, assign, readonly) long strategyVersion;

// This data should only be used for tests. DO NOT directly access.
@property (nonatomic, strong, readonly) JSValue *strategyData;

/**
 Caches the loaded strategies for reuse and requerying without hitting the disk.
 @param strategyName the name of the strategy file to be accessed. Case Sensitive.
 @param reloadData YES to refresh the cache entry from file. NO to go straight to cache unless it's a miss.
 @returns a dictionary with the most recently loaded copy of the specified strategy
 */
+ (BSMediaStrategy *)cacheForStrategyName:(NSString *)strategyName;

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
- (instancetype)initWithStrategyName:(NSString *)strategyName;

/**
    @return Returns name of that media stratery.
 */
-(NSString *)displayName; // Required override in subclass.

/**
    @return A Boolean saying if this is a tab that accepts this strategy.
 */
-(BOOL)accepts:(TabAdapter *)tab; // Required override in subclass.


/**
    @param methodName the name of the method to check if is implemented by this strategy
    @return A Boolean indicating if this strategy has implemented the provided method name
 */
- (BOOL)testIfImplemented:(NSString * _Nonnull)methodName;

/**
    @return A Boolean saying if this tab is in the playback state.
 */
- (BOOL)isPlaying:(TabAdapter *)tab;

/**
    @return Returns track information object from tab.
 */
- (BSTrack *)trackInfo:(TabAdapter *)tab;


// Methods, which return javascript code for apropriated actions.
//---------------------------------------------------------------

/**
    @return Returns javascript code of the play/pause toggle.
 */
-(NSString *)toggle; // Required override in subclass.

/**
    @return Returns javascript code of the previous track action.
 */
-(NSString *)previous;

/**
    @return Returns javascript code of the next track action.
 */
-(NSString *)next;

/**
    @return Returns javascript code of the pausing action. Used mainly for pausing before switching active tabs.
 */
-(NSString *)pause; // Required override in subclass.

/**
    @return Returns javascript code of the "favorite" toggle.
 */
-(NSString *)favorite;

@end
