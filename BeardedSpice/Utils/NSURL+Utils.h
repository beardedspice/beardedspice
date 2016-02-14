//
//  NSURL+Utils.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Utils)

/**
 Downloads data from that URL.
 @return NSData object, which contains requested data, or nil on failure.
 */
- (NSData *)getDataWithTimeout:(NSTimeInterval)timeout;

@end
