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

@end
