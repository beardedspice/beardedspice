//
//  TabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class runningSBApplication;

@interface TabAdapter : NSObject{
    
    BOOL _wasActivated;
}

-(id) executeJavascript:(NSString *) javascript;
-(NSString *) title;
-(NSString *) URL;
-(NSString *) key;
- (BOOL)check;

- (void)activateTab;
- (void)toggleTab;
- (BOOL)frontmost;

@property runningSBApplication *application;

/**
    Copying of the variables, which reflect state of the object.
 
    @param tab Object from which performed copying.
 
    @return Returns self.
 */
- (instancetype)copyStateFrom:(TabAdapter *)tab;

-(BOOL) isEqual:(__autoreleasing id)otherTab;

@end
