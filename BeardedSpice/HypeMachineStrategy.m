//
//  HypeMachineStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "HypeMachineStrategy.h"

@implementation HypeMachineStrategy

-(BOOL) accepts:(NSString *)url
{
    return [url isCaseInsensitiveLike:@"*hypem.com*"];
}

-(NSString *) toggle
{
    return @"(function(){return document.querySelectorAll('#playerPlay')[0].click()})()";
}

-(NSString *) previous
{
    return @"(function(){return document.querySelectorAll('#playerPrev')[0].click()})()";
}

-(NSString *) next
{
    return @"(function(){return document.querySelectorAll('#playerNext')[0].click()})()";
}

@end
