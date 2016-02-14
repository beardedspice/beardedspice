//
//  NSURL+Utils.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "NSURL+Utils.h"

@implementation NSURL (Utils)

/**
    Downloads data from that URL.
    @return NSData object, which contains requested data, or nil on failure.
 */
- (NSData *)getDataWithTimeout:(NSTimeInterval)timeout {

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

@end
