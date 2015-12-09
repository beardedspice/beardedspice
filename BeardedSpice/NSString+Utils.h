//
//  NSString+Utils.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

+ (BOOL)isNullOrEmpty:(NSString *)str;
+ (BOOL)isNullOrWhiteSpace:(NSString *)str;
+ (NSString *)stringByTrim:(NSString *)str;
/**
 @return index of string into receiver, or -1 if not found
 */
- (NSInteger)indexOf:(NSString *)string fromIndex:(NSUInteger)index;
/**
 @return index of string into receiver, or -1 if not found
 */
- (NSInteger)indexOf:(NSString *)string;

/**
 Returns converted string where:
 \ symbol replaced on \\,
 ' symbol replaced on \',
 " symbol replaced on \".
 */
- (NSString *)stringForSubstitutionInJavascriptPlaceholder;

@end
