//
//  BeardedSpiceControllers.h
//  BeardedSpiceControllers
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>
#import "BeardedSpiceControllersProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface BeardedSpiceControllers : NSObject <BeardedSpiceControllersProtocol>

@property (weak) NSXPCConnection *connection;

@end
