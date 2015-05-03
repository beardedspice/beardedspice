//
//  MediaControllerObject.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 02.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaControllerObject : NSObject

- (id)initWithObject:(id)object;

@property BOOL isGroup;
@property NSString *name;
@property BOOL isAuto;
@property id representationObject;

@end
