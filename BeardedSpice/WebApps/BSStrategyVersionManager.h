//
//  BSStrategyVersionManager.h
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

/**
 Used for notifying that supported strategies was modified.
 */
extern NSString *BSVMStrategyChangedNotification;

extern NSString *const BSVMStrategyErrorDomain;
/// Manifest for unsupported strategies does not contain data
#define BSVMS_ERROR_MANIFEST_DOWNLOAD        100
/// Manifest for unsupported strategies has invalid format
#define BSVMS_ERROR_MANIFEST_PARSE           200


@class BSStrategyCache;

/**
  Load currently saved version index
  At specified time, download a copy of the remote version index from the git repo
  Save the new index and download updated JS if any exist
  At query time, if a strategy is being or will be used, reload the cached strategy object.
 */
@interface BSStrategyVersionManager : NSObject

@property (class, readonly) BSStrategyVersionManager *singleton;

/**
 Downloads the versions.plist file from the target repository URL and checks if any new strategy template
 versions are marked as higher version than the currently loaded number.
 */
- (void)updateStrategiesWithCompletion:(void (^)(NSArray<NSString *> *updatedNames, NSError *error))completion;

/**
 Subfunction of performUpdateCheck.
 @param mediaStrategy the name of the strategy template to download to file and reload into memory.
 @return Boolean saying whether the operation was successful.
 */
- (BOOL)performUpdateOfMediaStrategy:(NSString *)mediaStrategy;

@end
