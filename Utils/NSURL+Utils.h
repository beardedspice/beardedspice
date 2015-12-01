//
//  NSURL+Utils.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

@import Foundation;

@interface NSURL (BSUtils)

/**
 Downloads data from that URL.
 @return NSData object, which contains requested data, or nil on failure.
 */
- (NSData *)getDataWithTimeout:(NSTimeInterval)timeout;


/**
 Constant path to the versions file copied to documents.
 DOES NOT provide a path to the bundled version that comes with the binary.
 @return path to where a mutable version of the versions.plist file is to be held.
 */
+ (NSURL * _Nonnull)versionsFileFromURL;

/**
 */
+ (NSURL * _Nonnull)fileFromURL:(NSString * _Nullable)fileName;

/**
 Simple wrapper for checking if the given file path exists
 @return BOOL yes/no if a file exists at the given filepath.
 */
- (BOOL)fileExists;

/**
 @param targetFileName Name of the file to be copied to the app support directory
 @return Boolean saying if the operation was successful or not.
 */
- (BOOL)copyFileTo:(NSString * _Nonnull)targetFileName;

@end
