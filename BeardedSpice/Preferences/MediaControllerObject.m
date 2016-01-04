//
//  MediaControllerObject.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 02.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaControllerObject.h"

@implementation MediaControllerObject

- (id)initWithObject:(id)object{
    
    self = [super init];
    if (self) {
        if ([object respondsToSelector:@selector(displayName)]) {
            _name = [object displayName];
        }
        if ([[object class] instancesRespondToSelector:@selector(isPlaying)] || [[object class] instancesRespondToSelector:@selector(isPlaying)]) {
            _isAuto = YES;
        }
        
        _representationObject = object;
    }
    
    return self;
}

- (id)init{
    
    return [self initWithObject:nil];
}

@end
