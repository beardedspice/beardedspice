//
//  TabAdapter.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 11.04.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabAdapter : NSObject

-(id) executeJavascript:(NSString *) javascript;
-(NSString *) title;
-(NSString *) URL;
-(NSString *) key;

- (void)activateTab;
- (void)toggleTab;
- (BOOL)frontmost;

-(BOOL) isEqual:(__autoreleasing id)otherTab;

@end
