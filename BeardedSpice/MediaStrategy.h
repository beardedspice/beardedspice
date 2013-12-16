//
//  MediaStrategy.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

@interface MediaStrategy : NSObject

-(BOOL) accepts:(NSString *)url;
-(NSString *) toggle;
-(NSString *) previous;
-(NSString *) next;

@end
