//
//  BSTimeout.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 12.02.16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>

@interface BSTimeout : NSObject

+ (id)timeoutWithInterval:(NSTimeInterval)interval;

- (BOOL)reached;

@end
