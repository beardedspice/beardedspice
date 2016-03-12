//
//  BSTimeout.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 12.02.16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//

#import "BSTimeout.h"

@implementation BSTimeout{
    
    NSDate *_startDate;
    NSTimeInterval _interval;
}

+ (id)timeoutWithInterval:(NSTimeInterval)interval{
    
    BSTimeout *timeout = [BSTimeout new];
    timeout->_startDate = [NSDate date];
    timeout->_interval = -interval;
    
    return timeout;
}

- (BOOL)reached{
    
    return ([_startDate timeIntervalSinceNow] < _interval);
}

@end
