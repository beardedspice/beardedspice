//
//  MediaHandler.h
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tab.h"

@interface MediaHandler : NSObject

+(BOOL) isValidFor:(NSString *)url;
+(id) initWithTab:(Tab *)tab;

-(void) toggle;
-(void) previous;
-(void) next;

@property Tab *tab;

@end
