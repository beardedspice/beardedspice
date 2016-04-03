//
//  NSException+Utils.h
//  Commons
//
//  Created by Roman Sokolov on 05.02.14.
//
//

#import <Foundation/Foundation.h>

@interface NSException (Utils)

+ (NSException *)argumentException:(NSString *)agrumentName;

/**
 Create NSException on allocation memory error.
 
 @param objectName Name of object. May be nil.
 
 */
+ (NSException *)mallocException:(NSString *)objectName;

/**
 Create NSException on application resource available error.
 
 @param resourceName name of app resource (file name and so on). May be nil.
 
 */
+ (NSException *)appResourceUnavailableException:(NSString *)resourceName;

/**
 Create NSException on selector that does not implemented.
 */
+ (NSException *)notImplementedException;

@end
