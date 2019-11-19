//
//  BSTVTabAdapter.m
//  Beardie
//
//  Created by Roman Sokolov on 13.11.2019.
//  Copyright © 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSTVTabAdapter.h"

#define APPID       @"com.apple.TV"
#define APPNAME     @"TV"

@implementation BSTVTabAdapter

+ (NSString *)displayName {
    static NSString *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        name = [super displayName];
    });
    return name ?: APPNAME;
}

+ (NSString *)bundleId{
    return APPID;
}

@end
