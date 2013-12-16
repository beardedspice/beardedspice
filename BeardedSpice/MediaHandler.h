//
//  MediaHandler.h
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "Tab.h"

@interface MediaHandler : NSObject

+(BOOL) isValidFor:(NSString *)url;
+(id) initWithTab:(id <Tab>)tab;

-(void) toggle;
-(void) previous;
-(void) next;

@property id <Tab> tab;

@end
