//
//  EHSystemUtils.m
//  EightHours
//
//  Created by Roman Sokolov on 01.03.16.
//  Copyright © 2016 Roman Sokolov. All rights reserved.
//

#import "EHSystemUtils.h"
#import "NSException+Utils.h"
#import <stdlib.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - EHSystemUtils
/////////////////////////////////////////////////////////////////////

@implementation EHSystemUtils

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods
/////////////////////////////////////////////////////////////////////

+ (BOOL)rootPrivileges{
    
    return !(geteuid());
}

+ (int)cliUtil:(NSString *)utilPath arguments:(NSArray *)arguments outputData:(NSData **)outputData{
    
    NSData *data;
    int result = 0;
    
    @autoreleasepool {
        
        if (!utilPath) {
            [[NSException argumentException:@"utilPath"] raise];
        }
        if (!arguments) {
            arguments = @[];
        }
        
        NSTask *task = [[NSTask alloc] init];
        
        task.launchPath = utilPath;
        task.arguments = arguments;
        
        
        NSPipe *pipe;
        
        if (outputData) {
            pipe = [NSPipe pipe];
            task.standardOutput = pipe;
            task.standardError = pipe;
        }
        
        [task launch];
        
        if (outputData) {
            data = [[pipe fileHandleForReading] readDataToEndOfFile];
        }
        
        [task waitUntilExit];
        
        result = task.terminationStatus;
    }
    
    if (outputData) {
        
        *outputData = data;
    }
    
    return result;
}

+ (int)cliUtil:(NSString *)utilPath arguments:(NSArray *)arguments output:(NSString **)output{
    
    NSString *outputString;
    int result = 0;
    NSData *data;
    
    if (output) {
        
        result = [EHSystemUtils cliUtil:utilPath arguments:arguments outputData:&data];
    }
    else {
        
        result = [EHSystemUtils cliUtil:utilPath arguments:arguments outputData:NULL];
    }
    
    
    if (output) {
        outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!outputString){
            outputString = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
        }
        
        *output = outputString;
    }
    
    return result;
}

+ (NSString *)createUUID{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef cfString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    NSString *result = [(__bridge NSString *)cfString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    CFRelease(cfString);
    
    return result;
}

@end
