//
//  MediaHandlerRegistry.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaHandler.h"
#import "Tab.h"

@interface MediaHandlerRegistry : NSObject
{
    NSMutableArray *availableHandlers;
}

+(id) addDefaultMediaHandlerClasses:(MediaHandlerRegistry *) registry;
+(id) getDefaultRegistry;

-(void) addMediaHandlerClass:(Class) clazz;
-(void) removeMediaHandlerClass:(Class) clazz;
-(void) containsMediaHandlerClass:(Class) clazz;
-(MediaHandler *) getMediaHandlerForTab:(id <Tab>) tab;

@end
