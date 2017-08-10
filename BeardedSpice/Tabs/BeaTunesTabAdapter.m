//
//  BeaTunesAdapter.m
//  BeardedSpice
//
//  Requires beaTunes 5.0.3 or later
//
//  Created by Hendrik Schreiber on 8/6/17.
//  Copyright © 2017 Hendrik Schreiber. All rights reserved.
//

#import "BeaTunesTabAdapter.h"
#import "NSString+Utils.h"
#import "BSMediaStrategy.h"
#import "BSTrack.h"
#import "BSTrack.h"
#import "FastSocket.h"


#define APPNAME_BEATUNES         @"beaTunes"
#define APPID_BEATUNES           @"com.tagtraum.beatunes"

@implementation BeaTunesTabAdapter{
    NSURL *_portFileURL;
    BOOL _beaTunesNeedDisplayNotification;
}

+ (NSString *)displayName{
    return APPNAME_BEATUNES;
}

+ (NSString *)bundleId{
    return APPID_BEATUNES;
}

//////////////////////////////////////////////////////////////
#pragma mark Communication With beaTunes
//////////////////////////////////////////////////////////////

- (NSURL *)portFileURL {
    if (!_portFileURL) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSArray *urls = [fileManager URLsForDirectory: NSApplicationSupportDirectory
                                            inDomains: NSUserDomainMask];
        if ([urls count] > 0) {
            NSURL *url = [urls objectAtIndex: 0];
            _portFileURL = [url URLByAppendingPathComponent: @"beatunes/remotecontrol.port"
                                                isDirectory: NO];
        }
    }
    return _portFileURL;
}

// Connect to 127.0.0.1 and send actionId to execute a beaTunes action
- (NSDictionary *) callAction:(NSString *)actionId {
    NSURL *portFileURL = [self portFileURL];
    if (!portFileURL) {
        return @{
                 @"status" : @"error",
                 @"message" : @"Failed to find port file"
                 };
    }
    NSString *port = [NSString stringWithContentsOfURL: portFileURL
                                              encoding: NSASCIIStringEncoding
                                                 error: nil];
    FastSocket *client = [[FastSocket alloc] initWithHost: @"127.0.0.1"
                                                  andPort: port];
    if (![client connect]) {
        return @{
                 @"status" : @"error",
                 @"message" : @"Failed to connect with beaTunes"
                 };
    }
    NSData *data = [[actionId stringByAppendingString: @"\n"] dataUsingEncoding: NSUTF8StringEncoding];
    [client sendBytes: [data bytes]
                count: [data length]];
    
    char buf[1024];
    NSMutableData *resultData = [NSMutableData dataWithCapacity: 1024];
    long received = 0;
    while ((received = [client receiveBytes: buf
                                      count: (1024)]) > 0) {
        [resultData appendBytes: buf
                         length: received];
    }
    [client close];
    return [self toDict: resultData];
}


- (NSDictionary *) toDict: (NSData *)data {
    NSString *string;
    string = [[NSString alloc] initWithData: data
                                   encoding: NSUTF8StringEncoding];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData: data
                                                options: 0
                                                  error: &error];
    if (error) {
        return @{
                 @"status" : @"error",
                 @"message" : [error description]
                 };
    }
    
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
        return results;
    }
    else
    {
        return @{
                 @"status" : @"error",
                 @"message" : @"Expected dictionary, but got something else",
                 @"content" : [object description]
                 };
    }
}

//////////////////////////////////////////////////////////////
#pragma mark Access App
//////////////////////////////////////////////////////////////

- (NSString *)title {
    @autoreleasepool {
        
        NSString *title;
        NSDictionary *result = [self callAction: @"audioplayer.track"];
        if ([result[@"status"] isEqual: @"ok"]) {
            NSDictionary *track = result[@"track"];
            if (![NSString isNullOrEmpty:track[@"name"]])
                title = track[@"name"];
            
            if (![NSString isNullOrEmpty: track[@"artist"]]) {
                
                if (title)
                    title = [title stringByAppendingFormat: @" - %@", track[@"artist"]];
                else
                    title = track[@"artist"];
            }
        }
        
        if ([NSString isNullOrEmpty:title]) {
            title = NSLocalizedString(@"No Track", @"iTunesTabAdapter");
        }
        
        return [NSString stringWithFormat: @"%@ (%@)", title, APPNAME_BEATUNES];
    }
}

- (NSString *)URL{
    return @"beaTunes";
}

// We have only one window.
- (NSString *)key{
    return @"A:beatunes";
}

// We have only one window.
-(BOOL) isEqual:(__autoreleasing id)otherTab{
    if (otherTab == nil || ![otherTab isKindOfClass: [BeaTunesTabAdapter class]]) return NO;
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark Player control methods
//////////////////////////////////////////////////////////////

- (void)toggle{
    [self callAction: @"audioplayer.pause.play"];
    _beaTunesNeedDisplayNotification = YES;
}

- (void)pause{
    [self callAction: @"audioplayer.pause"];
    _beaTunesNeedDisplayNotification = YES;
}

- (void)next{
    [self callAction: @"audioplayer.next"];
    _beaTunesNeedDisplayNotification = NO;
}

- (void)previous{
    [self callAction: @"audioplayer.previous"];
    _beaTunesNeedDisplayNotification = NO;
}

- (void)favorite{
    [self callAction: @"audioplayer.love.toggle"];
    _beaTunesNeedDisplayNotification = YES;
}

- (BSTrack *)trackInfo {
    NSDictionary *result = [self callAction: @"audioplayer.track"];
    if ([result[@"status"] isEqual: @"ok"]) {
        NSDictionary *t = result[@"track"];
        
        BSTrack *track = [BSTrack new];
        track.track = t[@"name"];
        track.album = t[@"album"];
        track.artist = t[@"artist"];
        track.favorited = [NSNumber numberWithBool: [@"Loved" isEqual: t[@"liking"]]];
        
        // fetch image
        NSDictionary *resultImage = [self callAction: @"audioplayer.image"];
        if ([resultImage[@"status"] isEqual: @"ok"]) {
            NSArray *images = resultImage[@"images"];
            if ([images count] > 0) {
                NSDictionary *image = images[0];
                NSData *imageData = [[NSData alloc] initWithBase64EncodedString: image[@"data"] options:0];
                track.image = [[NSImage alloc] initWithData: (NSData *)imageData];
            }
        }
        
        NSURL *url = [NSURL URLWithString: t[@"location"]];
        
        if (url) {
            NSLog(@"URL: %@", url);
        }
        return track;
    }
    return nil;
}

- (BOOL)isPlaying{
    NSDictionary *result = [self callAction: @"audioplayer.playing"];
    if ([result[@"status"] isEqual: @"ok"]) {
        return [result[@"playing"] boolValue];
    }
    return NO;
}

- (BOOL)showNotifications{
    return _beaTunesNeedDisplayNotification;
}


@end
