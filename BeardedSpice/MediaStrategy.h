//
//  MediaStrategy.h
//  BeardedSpice
//
//  Created by Jose Falcon on 12/15/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//

#import "TabAdapter.h"
#import <AppleGuice/AppleGuiceInjectable.h>

@protocol MediaStrategyProtocol <AppleGuiceInjectable>
@end

@interface Track : NSObject

-(NSUserNotification *) asNotification;

@property NSString *track;
@property NSString *album;
@property NSString *artist;

@property NSImage *image;
@property NSNumber *favorited;

@end

@interface MediaStrategy : NSObject{
    
    // Caches last image for optimization :)
    NSString *_lastImageUrlString;
    NSImage *_lastImage;

}

/**
    Returns name of that media stratery. 
 */
-(NSString *) displayName; // Required override in subclass.

/**
    Checks tab that it is accepted this strategy.
 */
-(BOOL) accepts:(TabAdapter *)tab; // Required override in subclass.

/**
    Checks tab that it is in the playback state.
 */
- (BOOL)isPlaying:(TabAdapter *)tab;

/**
    Returns track information object from tab.
 */
- (Track *)trackInfo:(TabAdapter *)tab;


// Methods, which return javascript code for apropriated actions.
//---------------------------------------------------------------

/**
    Returns javascript code of the play/pause toggle.
 */
-(NSString *) toggle; // Required override in subclass.

/**
    Returns javascript code of the previous track action.
 */
-(NSString *) previous;

/**
    Returns javascript code of the next track action.
 */
-(NSString *) next;

/**
    Returns javascript code of the pausing action.
    Used mainly for pausing before switching active tabs.
 */
-(NSString *) pause; // Required override in subclass.

/**
    Returns javascript code of the "favorite" toggle.
 */
-(NSString *) favorite;

//---------------------------------------------------------------

/**
    Helper method for obtaining album artwork from url string
 */
- (NSImage *)imageByUrlString:(NSString *)urlString;

@end
