//
//  BSHidAppleRemote.m
//  testRemote
//
//  Created by Roman Sokolov on 12.08.15.
//  Copyright (c) 2015 Roman Sokolov. All rights reserved.
//

#import "BSHidAppleRemote.h"

@implementation BSHidAppleRemote

- (void)addMappingValue:(NSInteger)value forKey:(NSString *)key{
    
    if (!(key && [key isKindOfClass:[NSString class]])) {
        return;
    }
    self->mCookieToButtonMapping[key] = @(value);
}

@end
