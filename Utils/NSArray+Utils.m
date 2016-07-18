//
//
//  Created by Roman Sokolov on 12.02.14.
//  Copyright (c) 2014 Roman Sokolov. All rights reserved.
//

#import "NSArray+Utils.h"


/// Stack methods for NSMutableArray
@implementation NSMutableArray (Stack)

- (id)pop
{
    id obj = [self lastObject];
    if (obj) {
        [self removeLastObject];
    }
    
    return obj;
}
- (void)push:(id)obj
{
    [self addObject:obj];
}
- (id)peekStack
{
    return [self lastObject];
}

@end

/// Queue methods for NSMutableArray
@implementation NSMutableArray (Queue)

- (id)dequeue;
{
    id obj = [self firstObject];
    if (obj) {
        [self removeObjectAtIndex:0];
    }
    
    return obj;
}
- (void)enqueue:(id)obj
{
    [self addObject:obj];
}
- (id)peekQueue
{
    return [self firstObject];
}

@end
