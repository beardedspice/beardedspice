//
//
//  Created by Roman Sokolov on 12.02.14.
//  Copyright (c) 2014 Roman Sokolov. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Stack methods for NSMutableArray
@interface NSMutableArray (Stack)

- (id)pop;
- (void)push:(id)obj;
- (id)peekStack;

@end

/// Queue methods for NSMutableArray
@interface NSMutableArray (Queue)

- (id)dequeue;
- (void)enqueue:(id)obj;
- (id)peekQueue;

@end
