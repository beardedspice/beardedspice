//
//  BSSharedResources.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 20.08.2018.
//  Copyright © 2018  GPL v3 http://www.gnu.org/licenses/gpl.html
//
#define LOG_LEVEL_DEF ddLogLevel
#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

typedef void (^BSSListenerBlock)(void);

/////////////////////////////////////////////////////////////////////
#pragma mark - BSSharedResources Constants

extern DDLogLevel ddLogLevel;
extern DDLogLevel DDDefaultLogLevel;

extern NSString *const BeardedSpicePlayPauseShortcut;
extern NSString *const BeardedSpiceNextTrackShortcut;
extern NSString *const BeardedSpicePreviousTrackShortcut;
extern NSString *const BeardedSpiceActiveTabShortcut;
extern NSString *const BeardedSpiceFavoriteShortcut;
extern NSString *const BeardedSpiceNotificationShortcut;
extern NSString *const BeardedSpiceActivatePlayingTabShortcut;
extern NSString *const BeardedSpicePlayerNextShortcut;
extern NSString *const BeardedSpicePlayerPreviousShortcut;

extern NSString *const BeardedSpiceFirstRun;
extern NSString *const BeardieBrowserExtensionsFirstRun;

/**
 Timeout for command of the user iteraction.
 */
#define COMMAND_EXEC_TIMEOUT                10.0

/////////////////////////////////////////////////////////////////////
#pragma mark - BSSharedResources

/**
     Class, which provides exchanging data between app and extension.
 */
@interface BSSharedResources : NSObject

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods

/**
 Returns URL where is shared resources.
 */
@property (class, readonly) NSURL *sharedResuorcesURL;
/**
 Returns shared user defaults object.
 */
@property (class, readonly) NSUserDefaults *sharedDefaults;

/// Init logger for process.
/// @param name Name of the folder where will be log files (use bundleId, product name and so on)
+ (void)initLoggerFor:(NSString *)name;

/**
 Performs flush of the shared user defaults.
 */
+ (void)synchronizeSharedDefaults;

/**
 Register listener for changing the tab port.

 @param block Performed on internal thread when catched notification.
 */
+ (void)setListenerOnTabPortChanged:(BSSListenerBlock)block;

@property (class) NSUInteger tabPort;

/**
 Register listener for changing the accepters.

 @param block Performed on internal thread when catched notification.
 */
+ (void)setListenerOnAcceptersChanged:(BSSListenerBlock)block;

/**
 Saves strategies accepters JSON in shared storage.
 Completion is executed on global concurent queue.

 @param accepters Accepters dictionary, may be nil.
 @param completion May be nil.
 */
+ (void)setAccepters:(NSDictionary *)accepters completion:(void (^)(void))completion;

/**
 Gets the strategies accepters dictionary from shared storage.
 Completion is executed on global concurent queue.
   */
+ (void)acceptersWithCompletion:(void (^)(NSDictionary *accepters))completion;

@end