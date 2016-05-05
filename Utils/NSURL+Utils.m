//
//  NSURL+Utils.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NSURL+Utils.h"

@implementation NSURL (BSUtils)

/**
    Downloads data from that URL.
    @return NSData object, which contains requested data, or nil on failure.
 */
- (NSData * _Nullable)getDataWithTimeout:(NSTimeInterval)timeout {

    @autoreleasepool {

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                initWithURL:self
                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
            timeoutInterval:timeout];

        if (!request)
            return nil;

        [request setHTTPMethod:@"GET"];

        NSURLResponse *response;
        NSError *error;

        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];

        // here we check for any returned NSError from the server, "and" we also
        // check for any http response errors
        if (error != nil)
            NSLog(@"(NSURL+Utils) Error loading data from \"%@\":%@",
                  [self absoluteString], [error localizedDescription]);

        else {
            // check for any response errors
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            UInt16 statusCode = [httpResponse statusCode] / 100;

            if (statusCode == 2)
                return data;

            else {

                NSLog(@"(NSURL+Utils) Http Error when loading data from "
                      @"\"%@\". Http Status:%li",
                      [self absoluteString], [httpResponse statusCode]);
            }
        }

        return nil;
    }
}

#pragma mark - File Operations

+ (NSURL *)versionsFileFromURL
{
    return [self fileFromURL:@"versions"];
}

+ (NSURL *)fileFromURL:(NSString *)fileName
{
    NSArray *documentPaths =  NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths firstObject];
    fileName = fileName ? [NSString stringWithFormat:@"%@.plist", fileName] : @"";

    NSString *path = [NSString stringWithFormat:@"%@/BeardedSpice/MediaStrategies/%@", documentsDir, fileName];
    // if no filename length then its a directory reference
    return [[NSURL alloc] initFileURLWithPath:path isDirectory:fileName.length == 0];
}

- (BOOL)fileExists
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[self path]];
}

- (BOOL)copyFileTo:(NSString * _Nonnull)targetFilePath
{
    // file referenced by this nsstring does not exist. aborting.
    if (![self fileExists])
        return NO;

    NSURL *pathWithoutFile = [NSURL fileFromURL:nil];
    NSURL *targetURL = [NSURL fileFromURL:targetFilePath];

    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager createDirectoryAtURL:pathWithoutFile withIntermediateDirectories:YES attributes:nil error:&error];
    if (!ret)
    {
        NSLog(@"An error occured creating the path to %@: %@", targetURL, [error localizedDescription]);
        return ret;
    }

    ret = [fileManager copyItemAtURL:self toURL:targetURL error:&error];
    if (error)
        NSLog(@"An error occured while copying file %@: %@", targetURL, [error localizedDescription]);

    return ret;
}
@end
