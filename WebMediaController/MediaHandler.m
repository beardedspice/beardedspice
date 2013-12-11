//
//  MediaHandler.m
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaHandler.h"

@implementation MediaHandler

@synthesize tab;

+(BOOL) isValidFor:(NSString *)url
{
    return NO;
}

+(id) initWithTab:(id <Tab>)tab
{
    MediaHandler *handler = [[MediaHandler alloc] init];
    [handler setTab:tab];
    return handler;
}

-(void) toggle{}
-(void) previous{}
-(void) next{}

@end
