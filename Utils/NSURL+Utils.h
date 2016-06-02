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
 */
- (BOOL)createDirectoriesToURL;

/**
 Downloads data from that URL.
 @return NSData object, which contains requested data, or nil on failure.
 */
- (NSData * _Nullable)getDataWithTimeout:(NSTimeInterval)timeout;

/**
 Application Support path to the Bearded Spice official strategy folder.
 */
+ (NSURL * _Nonnull)URLForSavedStrategies;

/**
 Application Support path to the Bearded Spice third-party/custom strategy folder.
 This path is manually managed by any given client.
 */
+ (NSURL * _Nonnull)URLForCustomStrategies;

/**
 Constant path to the versions file copied to documents.
 DOES NOT provide a path to the bundled version that comes with the binary.
 @return path to where a mutable version of the versions.plist file is to be held.
 */
+ (NSURL * _Nonnull)URLForVersionsFile;

/**
 */
+ (NSURL * _Nonnull)URLForFileName:(NSString * _Nullable)fileName;

/**
 */
+ (NSURL * _Nonnull)URLForFileName:(NSString * _Nonnull)fileName ofType:(NSString * _Nonnull)typeString;

/**
 Simple wrapper for checking if the given file path exists
 @return BOOL yes/no if a file exists at the given filepath.
 */
- (BOOL)fileExists;

/**
 */
- (BOOL)directoryExists;

/**
 @param targetFileName Name of the file to be copied to the app support directory
 @return Boolean saying if the operation was successful or not.
 */
- (BOOL)copyStrategyToAppSupport:(NSString * _Nonnull)targetFileName;

@end
