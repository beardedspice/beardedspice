//
//  TabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "NSString+Utils.h"

#define KEY_NAME            @"X_BeardedSpice_UUID"
#define GET_KEY_FORMAT      @"(function(){return (window." KEY_NAME @" == undefined ? '': window." KEY_NAME @");})();"
#define SET_KEY_FORMAT      @"(function(){ window." KEY_NAME @" = '%@';})();"

@implementation TabAdapter

- (id)executeJavascript:(NSString *)javascript{
    
    return nil;
}

-(NSString *) title{
    
    return nil;
}
-(NSString *) URL{
    
    return nil;
}

-(NSString *) key{
    
    return [self assignKey];
}

- (void)activateTab{
    
}

- (void)toggleTab{

}
- (BOOL)frontmost{
    
    return NO;
}

- (instancetype)copyStateFrom:(TabAdapter *)tab{
    return self;
}

-(BOOL) isEqual:(__autoreleasing id)otherTab{

    @autoreleasepool {
        
        if (otherTab == nil || ![otherTab isKindOfClass:[self class]]) return NO;
        
        return [[self key] isEqualToString:[otherTab key]];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark Private methods
//////////////////////////////////////////////////////////////

- (NSString *)assignKey{
    @autoreleasepool {
        
        NSString *_key = [self executeJavascript:GET_KEY_FORMAT];
        
        if ([NSString isNullOrEmpty:_key]){
            
            _key = [NSString stringWithFormat:@"K:%@", [[NSUUID UUID] UUIDString]];
            _key = [NSString stringWithFormat:SET_KEY_FORMAT GET_KEY_FORMAT, _key];
            _key = [self executeJavascript:_key];
        }
        return _key;
    }
}

@end
