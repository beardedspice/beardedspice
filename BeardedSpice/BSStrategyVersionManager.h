//
//  BSStrategyVersionManager.h
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#define kBSVersionErrorNotFound     -1
#define kBSVersionErrorInvalidInput -2

/**
 FIXME
 */
extern NSString *BSVMStrategyChangedNotification;

@class BSStrategyCache;

/**
  Load currently saved version index
  At specified time, download a copy of the remote version index from the git repo
  Save the new index and download updated plists if any exist
  At query time, if a strategy is being or will be used, reload the cached strategy object.
 */
@interface BSStrategyVersionManager : NSObject

@property (nonatomic, strong, readonly) NSDate *lastUpdated;
@property (nonatomic, strong, readonly) NSURL *versionURL;
@property (nonatomic, strong, readonly) BSStrategyCache *strategyCache;

/**
 FIXME documentation about how strategyCache is the central point of ref
 */
- (instancetype)initWithStrategyCache:(BSStrategyCache *)cache;

/**
 @param mediaStrategy The filename of the strategy template to check.
 @return returns the version number for the version of the strategy found in the index plist (versions.plist)
 */
- (long)versionForMediaStrategy:(NSString *)mediaStrategy;

/**
 Downloads the versions.plist file from the target repository URL and checks if any new strategy template
 versions are marked as higher version than the currently loaded number.
 */
- (void)performUpdateCheck;

/**
 Performs the same function as performUpdateCheck
 @return returns the number of strategies that were updated.
 */
- (NSUInteger)performSyncUpdateCheck;

/**
 Subfunction of performUpdateCheck.
 @param mediaStrategy the name of the strategy template to download to file and reload into memory.
 @return Boolean saying whether the operation was successful.
 */
- (BOOL)performUpdateOfMediaStrategy:(NSString *)mediaStrategy;

@end
