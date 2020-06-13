//
//  main.m
//  BeardedSpiceControllers
//
//  Created by Roman Sokolov on 05.03.16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <Foundation/Foundation.h>
#import "BeardedSpiceControllers.h"
#import "BeardedSpiceHostAppProtocol.h"
#import "BSCService.h"
#import "BSSharedResources.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {

    DDLogDebug(@"New connection");
    
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(BeardedSpiceControllersProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    BeardedSpiceControllers *exportedObject = [BeardedSpiceControllers new];
    exportedObject.connection = newConnection;
    
    newConnection.exportedObject = exportedObject;
   
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(BeardedSpiceHostAppProtocol)];
    
    NSXPCConnection * __weak wConn = newConnection;
    newConnection.interruptionHandler = ^{
        
        [[BSCService singleton] removeConnection:wConn];
    };
    newConnection.invalidationHandler = ^{
        
        [[BSCService singleton] removeConnection:wConn];
    };
    

    if ([[BSCService singleton] addConnection:newConnection]) {
        // Resuming the connection allows the system to deliver more incoming messages.
        [newConnection resume];
        // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
        return YES;
    }
    else {
        [newConnection invalidate];
        return NO;
    }
}

@end

int main(int argc, const char *argv[])
{
    @autoreleasepool {
        
        [BSSharedResources initLoggerFor:BS_CONTROLLER_BUNDLE_ID];
        
        // Create the delegate for the service.
        ServiceDelegate *delegate = [ServiceDelegate new];
        
        // Set up the one NSXPCListener for this service. It will handle all incoming connections.
        NSXPCListener *listener = [NSXPCListener serviceListener];
        listener.delegate = delegate;
        
        NSProcessInfo *procInfo = [NSProcessInfo processInfo];
        [procInfo disableAutomaticTermination:@"Need for keyboard hotkeys"];
        
        // Touch to BSCService
        [BSCService singleton];
        
        // Resuming the serviceListener starts this service. This method does not return.
        [listener resume];
        return 0;
    }
}
