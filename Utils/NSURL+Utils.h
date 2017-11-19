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
 Path to the BeardedSpice bundle strategy folder.
 */
+ (NSURL * _Nonnull)URLForBundleStrategies;

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

@end
