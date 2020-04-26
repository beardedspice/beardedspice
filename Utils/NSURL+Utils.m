//
//  NSURL+Utils.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NSURL+Utils.h"
#import "NSException+Utils.h"

@implementation NSURL (BSUtils)


#pragma mark - File Paths and Operations

static inline NSString *appSupportPath() {
    NSArray *documentPaths =  NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    return [documentPaths firstObject];
}

+ (NSURL *_Nonnull)URLForSavedStrategies {
    
    static NSURL *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      NSString *pathString = [NSString
          stringWithFormat:@"%@/BeardedSpice/Strategies/", appSupportPath()];
      result = [NSURL fileURLWithPath:pathString isDirectory:YES];
    });
    return result;
}

+ (NSURL *_Nonnull)URLForCustomStrategies {
    
    static NSURL *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      NSString *pathString =
          [NSString stringWithFormat:@"%@/BeardedSpice/CustomStrategies/",
                                     appSupportPath()];
      result = [NSURL fileURLWithPath:pathString isDirectory:YES];
    });
    return result;
}

+ (NSURL * _Nonnull)URLForBundleStrategies{
    
    static NSURL *result;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        result = [[NSBundle mainBundle] resourceURL];
        result = [result URLByAppendingPathComponent:@"MediaStrategies"];
    });
    return result;
}

+ (NSURL * _Nonnull)URLForFileName:(NSString *)fileName
{
    return [self URLForFileName:fileName ofType:@"js"];
}

+ (NSURL * _Nonnull)URLForFileName:(NSString *)fileName ofType:(NSString * _Nonnull)typeString
{
    fileName = fileName ? [NSString stringWithFormat:@"%@.%@", fileName, typeString] : @"";

    return [[self URLForSavedStrategies] URLByAppendingPathComponent:fileName isDirectory:NO];
}

- (BOOL)createDirectoriesToURL
{
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager createDirectoryAtURL:self withIntermediateDirectories:YES attributes:nil error:&error];
    if (!ret || error)
        NSLog(@"An error occured creating the path to %@: %@", self, [error localizedDescription]);
    return ret;
}

- (BOOL)fileExists
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[self path] isDirectory:NULL];
}

@end
