//
//  MediaStrategy.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "Tab.h"

@interface MediaStrategy : NSObject

-(BOOL) accepts:(id <Tab>) tab;
-(NSString *) toggle;
-(NSString *) previous;
-(NSString *) next;
-(NSString *) displayName;

// mainly for pausing before switching active tabs
-(NSString *) pause;

@end
