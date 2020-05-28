//
//  BSCustomStrategyManager.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 25.06.16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>

@class BSMediaStrategy;

/**
 FIXME
 */
extern NSString *BSCStrategyChangedNotification;

extern NSString *const BSCStrategyErrorDomain;
/// Manifest for unsupported strategies does not contain data
#define BSCS_ERROR_MANIFEST_DOWNLOAD        100
/// Manifest for unsupported strategies has invalid format
#define BSCS_ERROR_MANIFEST_PARSE           200
/// Can't create folder for saving custom strategies
#define BSCS_ERROR_CREATE_SAVING_FOLDER     300

@interface BSCustomStrategyManager : NSObject

+ (BSCustomStrategyManager *)singleton;

- (BOOL)importFromUrl:(NSURL *)url
           completion:(void (^)(BSMediaStrategy *strategy, NSError *error))completion;

- (void)exportStrategy:(BSMediaStrategy *)strategy
              toFolder:(NSURL *)folderURL
             overwrite:(BOOL(^)(NSURL *pathToFile))overwrite
            completion:(void (^)(NSError *error))completion;

- (BOOL)removeStrategy:(BSMediaStrategy *)strategy
            completion:(void (^)(BSMediaStrategy *replacedStrategy, NSError *error))completion;

- (void)updateCustomStrategiesFromUnsupportedRepoWithCompletion:(void (^)(NSArray<NSString *> *updatedNames, NSError *error))completion;

- (void)downloadCustomStrategiesFromUnsupportedRepoTo:(NSURL *)targetUrl completion:(void (^)(NSURL *folderUrl, NSError *error))completion;

@end
