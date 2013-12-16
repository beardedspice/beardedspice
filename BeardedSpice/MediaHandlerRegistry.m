//
//  MediaHandlerRegistry.m
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaHandlerRegistry.h"

#import "YoutubeHandler.h"
#import "PandoraHandler.h"
#import "BandCampHandler.h"
#import "GroovesharkHandler.h"
#import "HypeMachineHandler.h"
#import "ChromeTabAdapter.h"
#import "SafariTabAdapter.h"
#import "SoundCloudHandler.h"

@implementation MediaHandlerRegistry

-(id) init
{
    self = [super init];
    if (self) {
        availableHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addMediaHandlerClass:(Class) clazz
{
    [availableHandlers addObject:clazz];
}

-(void) removeMediaHandlerClass:(Class) clazz
{
    [availableHandlers removeObject:clazz];
}

-(void) containsMediaHandlerClass:(Class) clazz
{
    [availableHandlers containsObject:clazz];
}

-(MediaHandler *) getMediaHandlerForTab:(id <Tab>) tab
{
    if (tab) {
        for (Class handler in availableHandlers) {
            if ([self isValidHandler:handler forUrl:[tab URL]]) {
                NSLog(@"%@ is valid for url %@", handler, [tab URL]);
                
                MediaHandler *mediaHandler = [[handler alloc] init];
                [mediaHandler setTab:tab];
                return mediaHandler;
            }
        }
    }
    return NULL;
}

+(id) addDefaultMediaHandlerClasses:(MediaHandlerRegistry *) registry
{
    [registry addMediaHandlerClass:[YoutubeHandler class]];
    [registry addMediaHandlerClass:[PandoraHandler class]];
    [registry addMediaHandlerClass:[BandCampHandler class]];
    [registry addMediaHandlerClass:[GroovesharkHandler class]];
    [registry addMediaHandlerClass:[HypeMachineHandler class]];
    [registry addMediaHandlerClass:[SoundCloudHandler class]];
    return registry;
}

+(id) getDefaultRegistry
{
    return [MediaHandlerRegistry addDefaultMediaHandlerClasses:[[MediaHandlerRegistry alloc] init]];
}

- (BOOL) isValidHandler:(Class) handler forUrl:(NSString *)url
{
    if (![handler isSubclassOfClass:[MediaHandler class]]) {
        return NO;
    }
    
    BOOL output;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[handler methodSignatureForSelector:@selector(isValidFor:)]];
    [inv setTarget:handler];
    [inv setSelector:@selector(isValidFor:)];
    [inv setArgument:&url atIndex:2]; // 0 is target, 1 is selector
    [inv invoke];
    [inv getReturnValue:&output];
    return output;
}

@end
