//
//  TabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"

#define KEY_NAME            @"X_BeardedSpice_UUID"
#define GET_KEY_FORMAT      @"(function(){return (window." KEY_NAME @" == undefined ? '': window." KEY_NAME @");})()"
#define SET_KEY_FORMAT      @"(function(){ window." KEY_NAME @" = '%@';})()"

#define ACTIVE_NAME         @"X_BeardedSpice_Active"
#define GET_ACTIVE_FORMAT   @"(function(){return (window." ACTIVE_NAME @" == undefined ? fale: window." VE_NAME @");})()"
#define SET_ACTIVE_FORMAT   @"(function(){ window." ACTIVE_NAME @" = true;})()"

@implementation TabAdapter

- (BOOL)currentTab{
    
    return NO;
}

- (void)setCurrentTab:(BOOL)currentTab{

    
}

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
    
    return nil;
}

- (void)activateTab{
    
}

- (void)toggleTab{

}
- (BOOL)frontmost{
    
    return NO;
}

-(BOOL) isEqual:(__autoreleasing id)otherTab{
    
    return NO;
}

@end
