//
//  BSLaunchAtLogin.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 21.06.15.
//  Copyright (c) 2015  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - BSLaunchAtLogin
/////////////////////////////////////////////////////////////////////

/**
 Manipulation of system preferences user login item.
 */
@interface BSLaunchAtLogin : NSObject

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods
/////////////////////////////////////////////////////////////////////

@property (nonatomic)   BOOL startAtLogin;
@property (copy, nonatomic, readonly)     NSString *identifier;

-(id)initWithIdentifier:(NSString*)identifier;

@end
