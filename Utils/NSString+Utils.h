//
//  NSString+Utils.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

@import Foundation;

// FIXME change filename to match namespacing of category
@interface NSString (BSUtils)

+ (BOOL)isNullOrEmpty:(NSString * _Nullable)str;
+ (BOOL)isNullOrWhiteSpace:(NSString * _Nullable)str;
+ (NSString * _Nullable)stringByTrim:(NSString * _Nonnull)str;
/**
 @return index of string into receiver, or -1 if not found
 */
- (NSInteger)indexOf:(NSString * _Nonnull)string fromIndex:(NSUInteger)index;
/**
 @return index of string into receiver, or -1 if not found
 */
- (NSInteger)indexOf:(NSString * _Nonnull)string;


- (BOOL)contains:(NSString *_Nonnull)str caseSensitive:(BOOL)sensitive;

/**
 @return the 'self' script string with '()' added to the end
 */
- (NSString * _Nonnull)makeFunctionExecute;

/**
 Returns converted string where:
 \ symbol replaced on \\,
 ' symbol replaced on \',
 " symbol replaced on \".
 */
- (NSString *_Nonnull)stringForSubstitutionInJavascriptPlaceholder;

@end
