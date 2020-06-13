//
//  TabAdapter.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import "BSTrack.h"
#import "NSString+Utils.h"
#import "runningSBApplication.h"

#define KEY_NAME            @"X_BeardedSpice_UUID"
#define RETURN_KEY_FORMAT   @"return (window." KEY_NAME @" == undefined ? '': window." KEY_NAME @");"
#define GET_KEY_FORMAT      @"(function(){" RETURN_KEY_FORMAT @"})()"
#define ASSIGN_KEY_FORMAT   @"(function(){ window." KEY_NAME @" = '%@';" RETURN_KEY_FORMAT @"})()"
#define CHECK_EXEC          @"(function(){ return 1;})()"

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

- (BOOL)activateApp{

    @autoreleasepool {

        if ([self.application frontmost] == NO) {

            BOOL result = [self.application activate];
            DDLogDebug(@"[self.application activate] = %d", result);
            return result;
        }
        self.application.wasActivated = NO;
    }
    return NO;
}

- (BOOL)deactivateApp {
    
    @autoreleasepool {
        
        if (self.application.wasActivated && [self.application frontmost]) {
            BOOL result = ![self.application hide];
            DDLogDebug(@"![self.application hide] = %d", result);
            return ! result;
        }
        self.application.wasActivated = NO;
    }
    
    return NO;
}

- (BOOL)activateTab {
    return YES;
}
- (BOOL)deactivateTab {
    @autoreleasepool {
        
        if (self.application.wasActivated && [self.application frontmost]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isActivated{
    return (self.application.wasActivated && [self.application frontmost]);
}

- (void)toggleTab{
}

- (BOOL)frontmost{

    return self.application.frontmost;
}

- (BOOL)showNotifications{
    return YES;
}

- (BOOL)isEqual:(id)object {

    @autoreleasepool {
        if (self == object) {
            return YES;
        }
        if (object == nil || ![object isKindOfClass:[self class]])
            return NO;

        return [[self key] isEqualToString:[object key]];
    }
}

- (NSUInteger)hash{

    return [[self key] hash];
}

- (BOOL)check{

    NSNumber *result = [self executeJavascript:CHECK_EXEC];
    return [result boolValue];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark Virtual methods

- (BOOL)toggle {
    return NO;
}
- (BOOL)pause {
    return NO;
}
- (BOOL)next {
    return NO;
}
- (BOOL)previous {
    return NO;
}
- (BOOL)favorite {
    return NO;
}

- (BSTrack *)trackInfo {
    return nil;
}
- (BOOL)isPlaying {
    return NO;
}

//////////////////////////////////////////////////////////////
#pragma mark Private methods
//////////////////////////////////////////////////////////////

- (NSString *)assignKey{
    @autoreleasepool {

        NSString *_key = [self executeJavascript:GET_KEY_FORMAT];

        if ([NSString isNullOrEmpty:_key]){

            _key = [NSString stringWithFormat:@"K:%@", [[NSUUID UUID] UUIDString]];
            _key = [NSString stringWithFormat:ASSIGN_KEY_FORMAT, _key];
            _key = [self executeJavascript:_key];
        }
        return _key;
    }
}

@end
