//
//  EHFileLocker.m
//  BeardedSpice
//
//  Created by Roman Sokolov on 28.10.14.
//  Copyright (c) 2018  GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "EHFileLocker.h"

/////////////////////////////////////////////////////////////////////
#pragma mark - ACLFileLocker
/////////////////////////////////////////////////////////////////////

@interface EHFileLocker()

@end

@implementation EHFileLocker

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods
/////////////////////////////////////////////////////////////////////

- (id)initWithPath:(NSString *)path{
    
    self = [super init]; // [super _init_];
    if (self)
    {
        _path = path;
        _fileDescriptor = -1;
        _locked = NO;
        
    }
    
    return self;
}

- (void)dealloc{
    
    if (_fileDescriptor >= 0){
        
        if (_locked)
            flock(_fileDescriptor, LOCK_UN);
        
        close(_fileDescriptor);
    }
}
/////////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods
/////////////////////////////////////////////////////////////////////////

- (BOOL)lock{
    
    @synchronized(self){
        
        if (_locked)
            return YES;
            
        if ([self open]) {

            if (flock(_fileDescriptor, LOCK_EX | LOCK_NB) == 0){
                
                _locked = YES;
                return YES;
            }
        }
        
        return NO;
    }
}

- (BOOL)waitLock{
    
    @synchronized(self){
        
        if (_locked)
            return YES;
        
        if ([self open]) {
            
            if (flock(_fileDescriptor, LOCK_EX ) == 0){
                
                _locked = YES;
                return YES;
            }
        }
        
        return NO;
    }
}

- (BOOL)unlock{
    
    @synchronized(self){
        
        if (!_locked)
            return YES;
        
        if (_fileDescriptor >= 0 && flock(_fileDescriptor, LOCK_UN ) == 0){
            
            _locked = NO;
            return YES;
        }
        
        return NO;
    }
}

////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods
////////////////////////////////////////////////////////////////////////////

- (BOOL)open{
    
    if (_fileDescriptor < 0) {
        _fileDescriptor = open([_path UTF8String], (O_CREAT | O_RDWR), (S_IRUSR | S_IWUSR));
        if (_fileDescriptor < 0)
            return NO;
    }

    return YES;
}

@end
