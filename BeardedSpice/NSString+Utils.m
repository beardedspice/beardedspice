//
//  NSString+Utils.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

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
    return [str stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

- (NSString *)stringForSubstitutionInJavascriptPlaceholder{
    
    NSString *sb = [self stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    sb = [sb stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    return [sb stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}


@end
