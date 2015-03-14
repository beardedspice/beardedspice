//
//  NSString+Utils.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 14.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+ (BOOL)isNullOrEmpty:(NSString *)str
{
    return (!str || [str isEqualToString:@""]);
}

+ (BOOL)isNullOrWhiteSpace:(NSString *)str
{
    return (!str || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]);
}

+ (NSString *)stringByTrim:(NSString *)str
{
    //TODO: WARINING
    // Old (commented) variant may be true
    // return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
