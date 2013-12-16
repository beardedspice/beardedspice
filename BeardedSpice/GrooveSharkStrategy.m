//
//  GrooveSharkStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "GrooveSharkStrategy.h"

@implementation GrooveSharkStrategy

-(BOOL) accepts:(NSString *)url
{
    return [url isCaseInsensitiveLike:@"*grooveshark.com*"];
}

-(NSString *) toggle
{
    return @"(function(){return window.Grooveshark.toggle()})()";
}

-(NSString *) previous
{
    return @"(function(){return window.Grooveshark.previous()})()";
}

-(NSString *) next
{
    return @"(function(){return window.Grooveshark.next()})()";
}

@end
