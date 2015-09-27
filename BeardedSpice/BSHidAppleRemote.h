//
//  BSHidAppleRemote.h
//  testRemote
//
//  Created by Roman Sokolov on 12.08.15.
//  Copyright (c) 2015 Roman Sokolov. All rights reserved.
//

#import <DDHidLib/DDHidLib.h>

enum{
    
    kDDHidRemoteButtonPlayPause = 100
};

@interface BSHidAppleRemote : DDHidAppleRemote

- (void)addMappingValue:(NSInteger)value forKey:(NSString *)key;

@end
