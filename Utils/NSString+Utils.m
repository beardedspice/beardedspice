//
//  NSString+Utils.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NSString+Utils.h"

// FIXME change filename to match namespacing of category
@implementation NSString (BSUtils)

#pragma mark - Query Operations

+ (BOOL)isNullOrEmpty:(NSString *)str {
    return (!str || [str length] == 0);
}

+ (BOOL)isNullOrWhiteSpace:(NSString *)str {
    return (!str ||
            [[str stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]] length] == 0);
}

+ (NSString *)stringByTrim:(NSString *)str {
    // TODO: WARINING
    // Old (commented) variant may be true
    // return [str stringByTrimmingCharactersInSet:[NSCharacterSet
    // whitespaceCharacterSet]];
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)trimToLength:(NSInteger)max
{
    if ([self length] > max) {
        return [NSString stringWithFormat:@"%@...", [self substringToIndex:(max - 3)]];
    }
    return [self substringToIndex: [self length]];
}

- (NSInteger)indexOf:(NSString *)string fromIndex:(NSUInteger)index {
    NSRange range =
        [self rangeOfString:string
                    options:NSLiteralSearch
                      range:NSMakeRange(index, self.length - index)];

    if (range.location == NSNotFound)
        return -1;
    return range.location;
}
- (NSInteger)indexOf:(NSString *)string {
    return [self indexOf:string fromIndex:0];
}

- (BOOL)contains:(NSString * _Nonnull)str caseSensitive:(BOOL)sensitive {
    if (sensitive)
        return ([self rangeOfString:str]).location != NSNotFound;

    return ([self rangeOfString:str options:NSCaseInsensitiveSearch]) .location != NSNotFound;
}

- (NSString * _Nonnull)addExecutionStringToScript
{
    // TODO add checks before hand to make sure we don't double execute
    // TODO add checks before hand ot make sure this is actually a func
    return [[NSString alloc] initWithFormat:@"(%@)()", self];
}

- (NSString *_Nonnull)stringForSubstitutionInJavascriptPlaceholder{

    NSString *sb = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    sb = [sb stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    sb = [sb stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    return [sb stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

- (NSAttributedString *)attributedStringFromTemplateInsertingLink:(NSArray <NSURL *> *)links
                                                        alignment:(NSTextAlignment)alignment
                                                             font:(NSFont *)font
                                                            color:(NSColor *)color {
    
    if (self.length == 0){
        return nil;
    }
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    style.alignment = alignment;
    NSFont *resultFont = font ?:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall]];
    NSMutableAttributedString *resultDescr = [[NSMutableAttributedString alloc]
                                              initWithString:self
                                              attributes:@{
                                                  NSForegroundColorAttributeName: color ?: [NSColor disabledControlTextColor],
                                                  NSFontAttributeName: resultFont,
                                                  NSParagraphStyleAttributeName: style
                                              }];
    
    if (links.count) {
        
        NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:@"(\\[[^\\]]+\\])(\\[\\d+\\])?" options:0 error:NULL];
        __block NSUInteger compensator = 0;
        [expr enumerateMatchesInString:self
                               options:0
                                 range:NSMakeRange(0, self.length)
                            usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            NSRange range = result.range;
            range.location -= compensator;
            
            NSUInteger linkIndex = 0;
            if (result.numberOfRanges == 3) {
                NSRange numberRange = [result rangeAtIndex:2];
                if (numberRange.location != NSNotFound) {
                    compensator += numberRange.length;
                    numberRange.location++;
                    numberRange.length -= 2;
                    
                    linkIndex = [[self substringWithRange:numberRange] integerValue] - 1;
                }
            }
            linkIndex = MIN(linkIndex, links.count - 1);
            NSRange linkRange = [result rangeAtIndex:1];
            //without brackets
            linkRange.location++;
            linkRange.length -= 2;
            
            NSAttributedString *attrLinkString = [[NSAttributedString alloc]
                                                  initWithString:[self substringWithRange:linkRange]
                                                  attributes:@{
//                                                           NSForegroundColorAttributeName: color ?: [NSColor disabledControlTextColor],
//                                                           NSFontAttributeName: resultFont,
                                                      NSParagraphStyleAttributeName: style,
                                                      NSLinkAttributeName: [links[linkIndex] absoluteString]
                                                  }];
            if (attrLinkString) {
                [resultDescr replaceCharactersInRange:range withAttributedString:attrLinkString];
                compensator += 2;
            }
        }];
        
        // reset style
        [resultDescr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, resultDescr.length)];
    }
    
    return [resultDescr copy];
}

@end

NSString* BSLocalizedString(NSString* key, NSString* comment) {
    NSString* localizedString = NSLocalizedString(key, @"");

    if ([localizedString isEqualToString:key]) {
        static NSBundle * languageBundle;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
            languageBundle = [NSBundle bundleWithPath:path];
        });

        localizedString = [languageBundle localizedStringForKey:key value:@"" table:nil] ?: @"";
    }
    return localizedString;
}
