//
//  EHFileLocker.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 28.10.14.
//  Copyright (c) 2018 BeardedSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////
#pragma mark - ACLFileLocker
/////////////////////////////////////////////////////////////////////

/**
    Implements locking of a file, which used as a primitive 
    locking mechanism in interprocess communications. 
 */
@interface EHFileLocker  : NSObject{
    
    int _fileDescriptor;
    BOOL _locked;
}

/////////////////////////////////////////////////////////////////////
#pragma mark Init and Class methods
/////////////////////////////////////////////////////////////////////

-(id)initWithPath:(NSString *)path;

/////////////////////////////////////////////////////////////////////
#pragma mark Properties and public methods
/////////////////////////////////////////////////////////////////////


@property (nonatomic, readonly) NSString *path;


- (BOOL)lock;
- (BOOL)waitLock;
- (BOOL)unlock;

@end
