//
//  NSException+Utils.m
//  Commons
//
//  Created by Roman Sokolov on 05.02.14.
//
//

#import "NSException+Utils.h"

@implementation NSException (Utils)

+ (NSException *)argumentException:(NSString *)argumentName{
    if (!argumentName)
        argumentName = @"(NONE)";
    
    return [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Method argument error: %@", argumentName] userInfo:nil];
}

+ (NSException *)mallocException:(NSString *)objectName{
    
    NSString *descriprion = @"Memory allocation error.";
    
    if (objectName) {
        
        descriprion = [descriprion stringByAppendingFormat:@" Attempt allocate memory for (%@).", objectName];
    }
    return [NSException exceptionWithName:NSMallocException reason:descriprion userInfo:nil];
}

+ (NSException *)appResourceUnavailableException:(NSString *)resourceName{
    
    NSString *description = @"Application resource available error.";
    
    if (resourceName) {
        
        description = [description stringByAppendingFormat:@" Attempt load resource with name: \"%@\".", resourceName];
    }
    return [NSException exceptionWithName:NSInternalInconsistencyException reason:description userInfo:nil];
    
}

+ (NSException *)notImplementedException{
    
    return [NSException exceptionWithName:NSInvalidArgumentException reason:@"Selector not implemented" userInfo:nil];
}

@end

NSException * _Nullable tryBlock(void(^_Nonnull block)(void)) {
    @try {
        block();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}
