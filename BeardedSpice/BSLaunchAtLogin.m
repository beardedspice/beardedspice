//
//  BSLaunchAtLogin.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 21.06.15.
//  Copyright (c) 2015  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSLaunchAtLogin.h"
#import <ServiceManagement/ServiceManagement.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - BSLaunchAtLogin
/////////////////////////////////////////////////////////////////////

@implementation BSLaunchAtLogin {
    NSURL    *_url;
    BOOL _enabled;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods
/////////////////////////////////////////////////////////////////////

-(id)initWithIdentifier:(NSString*)identifier {
    self = [self init];
    if(self) {
        _identifier = identifier;
        [self startAtLogin];
        DDLogInfo(@"Launcher '%@' %@ configured to start at login",
              self.identifier, (_enabled ? @"is" : @"is not"));
    }
    return self;
}

-(void)setIdentifier:(NSString *)identifier {

}

- (BOOL)startAtLogin {
    if (!_identifier)
        return NO;
    
    BOOL isEnabled  = NO;
    
    // the easy and sane method (SMJobCopyDictionary) can pose problems when sandboxed. -_-
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFArrayRef  cfJobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
#pragma clang diagnostic pop
    NSArray* jobDicts = CFBridgingRelease(cfJobDicts);
    
    if (jobDicts && [jobDicts count] > 0) {
        for (NSDictionary* job in jobDicts) {
            if ([_identifier isEqualToString:[job objectForKey:@"Label"]]) {
                isEnabled = [[job objectForKey:@"OnDemand"] boolValue];
                break;
            }
        }
    }
    
    if (isEnabled != _enabled) {
        [self willChangeValueForKey:@"enabled"];
        _enabled = isEnabled;
        [self didChangeValueForKey:@"enabled"];
    }
    
    return isEnabled;
}

- (void)setStartAtLogin:(BOOL)flag {
    if (!_identifier)
        return;
    
    [self willChangeValueForKey:@"startAtLogin"];
    
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)_identifier, (flag) ? true : false)) {
        DDLogError(@"SMLoginItemSetEnabled failed!");
        
    } else {
        [self willChangeValueForKey:@"enabled"];
        _enabled = flag;
        [self didChangeValueForKey:@"enabled"];
    }
    
    DDLogInfo(@"Launcher '%@' %@ configured to start at login",
              self.identifier, (_enabled ? @"is" : @"is not"));
    
    [self didChangeValueForKey:@"startAtLogin"];
}

@end
