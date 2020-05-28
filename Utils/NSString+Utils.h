//
//  NSString+Utils.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

@import Cocoa;

// FIXME change filename to match namespacing of category
@interface NSString (BSUtils)

+ (BOOL)isNullOrEmpty:(NSString * _Nullable)str;
+ (BOOL)isNullOrWhiteSpace:(NSString * _Nullable)str;
+ (NSString * _Nullable)stringByTrim:(NSString * _Nonnull)str;

/**
 */
-(NSString * _Nonnull)trimToLength:(NSInteger)max;

/**
 @return index of string into receiver, or -1 if not found
 */
- (NSInteger)indexOf:(NSString * _Nonnull)string fromIndex:(NSUInteger)index;
/**
 @return index of string into receiver, or -1 if not found
 */
- (NSInteger)indexOf:(NSString * _Nonnull)string;


- (BOOL)contains:(NSString * _Nonnull)str caseSensitive:(BOOL)sensitive;

/**
 @return the 'self' script string with '()' added to the end
 */
- (NSString * _Nonnull)addExecutionStringToScript;

/**
 Returns converted string where:
 \ symbol replaced on \\,
 ' symbol replaced on \',
 " symbol replaced on \".
 */
- (NSString *_Nonnull)stringForSubstitutionInJavascriptPlaceholder;

///  Returns attributed string from instance, which can be template,
///  where text in square brackets is replaced on text with link.
///  Instance can be template string, like: 'Some text. [Here] you [can][1] get [addition][2] info.'
/// @param links Urls for text in square beckets. Like this: @[(URL for: 'Here', 'can'), (URL for 'addition')]
/// @param alignment Text alignment. Default value is `NSTextAlignmentLeft` (it is 0).
/// @param font Text font, may be nil. Default value is `systemFont` `NSControlSizeSmall`.
/// @param color Foregraund color, may be nil. Default value is 'disabledControlTextColor'.
- (NSAttributedString *_Nullable)attributedStringFromTemplateInsertingLink:(NSArray <NSURL *> *_Nullable)links
                                                        alignment:(NSTextAlignment)alignment
                                                             font:(NSFont *_Nullable)font
                                                            color:(NSColor *_Nullable)color;

@end

#pragma mark - Public Fuctions

NSString* _Nonnull BSLocalizedString(NSString* _Nonnull key, NSString* _Nullable comment);
