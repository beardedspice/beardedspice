//
//  TabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "NSString+Utils.h"
#import "runningSBApplication.h"

#define KEY_NAME            @"X_BeardedSpice_UUID"
#define GET_KEY_FORMAT      @"(function(){return (window." KEY_NAME @" == undefined ? '': window." KEY_NAME @");})();"
#define SET_KEY_FORMAT      @"(function(){ window." KEY_NAME @" = '%@';})();"
#define CHECK_EXEC          @"(function(){ return 1;})();"

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
    
    @autoreleasepool {
        
        if (![self.application frontmost]) {
            
            [self.application activate];
            _wasActivated = YES;
        }
        else
            _wasActivated = NO;
    }
}

- (void)toggleTab{
    
    if ([self.application frontmost]){
        if (_wasActivated) {
            
            [self.application hide];
            _wasActivated = NO;
        }
    }
    else
        [self activateTab];
}

- (BOOL)frontmost{
    
    return self.application.frontmost;
}


- (instancetype)copyStateFrom:(TabAdapter *)tab{
    
    if ([tab isKindOfClass:[self class]]) {
        
        _wasActivated = tab->_wasActivated;
    }
    
    return self;
}

-(BOOL) isEqual:(__autoreleasing id)otherTab{

    @autoreleasepool {
        
        if (otherTab == nil || ![otherTab isKindOfClass:[self class]]) return NO;
        
        return [[self key] isEqualToString:[otherTab key]];
    }
}

- (BOOL)check{
    
    NSNumber *result = [self executeJavascript:CHECK_EXEC];
    return [result boolValue];
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
