//
//  TidalHiFiStrategy.h
//  BeardedSpice
//
//  Created by Roman Sokolov on 04.03.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "MediaStrategy.h"

@interface TidalHiFiStrategy : MediaStrategy{
    
    NSPredicate *predicate;
    
    // Caches last image for optimization :)
    NSString *_lastImageUrlString;
    NSImage *_lastImage;
}

@end
