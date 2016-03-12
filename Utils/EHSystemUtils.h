//
//  EHSystemUtils.h
//  EightHours
//
//  Created by Roman Sokolov on 01.03.16.
//  Copyright © 2016 Roman Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - EHSystemUtils
/////////////////////////////////////////////////////////////////////

/**
 Contains utilities for wrapping unix functions.
 */
@interface EHSystemUtils : NSObject

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods
/////////////////////////////////////////////////////////////////////

/**
 Checks that current process have root privileges.
 */
+ (BOOL)rootPrivileges;

/**
 Launches command line utility.
 @param utilPath Full path of cli utility. You MUST specify full path.
 @param arguments array with NSString objects, may be nil.
 @param outputData returning parameter. Set to NULL if we do not need it.
 */
+ (int)cliUtil:(NSString *)utilPath arguments:(NSArray *)arguments outputData:(NSData **)outputData;

/**
 Launches command line utility.
 @param utilPath Full path of cli utility. You MUST specify full path.
 @param arguments array with NSString objects, may be nil.
 @param output returning parameter. Set to NULL if we do not need it.
 */
+ (int)cliUtil:(NSString *)utilPath arguments:(NSArray *)arguments output:(NSString **)output;

/**
 Returns UUID (GUID).
 */
+ (NSString *)createUUID;


@end
