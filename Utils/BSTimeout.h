//
//  BSTimeout.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 12.02.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSTimeout : NSObject

+ (id)timeoutWithInterval:(NSTimeInterval)interval;

- (BOOL)reached;

@end
