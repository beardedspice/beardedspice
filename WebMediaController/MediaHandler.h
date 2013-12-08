//
//  MediaHandler.h
//  WebMediaController
//
//  Created by Tyler Rhodes on 12/8/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chrome.h"
@interface MediaHandler : NSObject
-(void) play:(ChromeTab *) tab;
-(void) pause:(ChromeTab *) tab;
-(void) previous:(ChromeTab *) tab;
-(void) next:(ChromeTab *) tab;
@end
