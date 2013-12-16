//
//  MediaStrategy.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@implementation MediaStrategy

-(BOOL) accepts:(NSString *)url
{
    return YES;
}
-(NSString *) toggle
{
    return @"";
}
-(NSString *) previous
{
    return @"";
}
-(NSString *) next
{
    return @"";
}

@end
