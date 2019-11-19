//
//  TabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
#import <Foundation/Foundation.h>

@class runningSBApplication, BSTrack;

@interface TabAdapter : NSObject 

@property (readonly) runningSBApplication *application;

-(id) executeJavascript:(NSString *) javascript;
-(NSString *) title;
-(NSString *) URL;
-(NSString *) key;
- (BOOL)check;

- (BOOL)activateApp;
- (BOOL)deactivateApp;

- (BOOL)activateTab;
- (BOOL)deactivateTab;
/**
 Determins if this tab was activated by user before.
 In this implementation means, that  app was activated.
 
 @return YES if user activated this app before and corresponding app is frontmost still.
 */
- (BOOL)isActivated;
/**
 Switches tab to frontmost/backmost.
 Abstract method, must be implemented in child classes.
 */
- (void)toggleTab;

/**
 Returns YES if app is frontmost, in this implementation.
 */
- (BOOL)frontmost;

/**
 Indicates when BeardedSpice may display notifications.
 */
- (BOOL)showNotifications;

/////////////////////////////////////////////////////////////////////////
#pragma mark Virtual methods

- (BOOL)toggle;
- (BOOL)pause;
- (BOOL)next;
- (BOOL)previous;
- (BOOL)favorite;

- (BSTrack *)trackInfo;
- (BOOL)isPlaying;

@end
