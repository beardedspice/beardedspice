//
//  BSNativeAppTabsController.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 09.11.17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>
#import "BSNativeAppTabAdapter.h"

@interface BSNativeAppTabsController : NSObject

/////////////////////////////////////////////////////////////////////////
#pragma mark Public properties and methods

+ (BSNativeAppTabsController *)singleton;

- (NSArray <BSNativeAppTabAdapter *> *)tabs;

@end
