//
//  BSTrack.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import "BSTrack.h"

NSString *const kBSTrackNameImage = @"image";
NSString *const kBSTrackNameTrack = @"track";
NSString *const kBSTrackNameAlbum = @"album";
NSString *const kBSTrackNameArtist = @"artist";
NSString *const kBSTrackNameFavorited = @"favorited";

@interface BSTrack ()

@property (nonatomic, strong) NSString *imageURL;

@property (nonatomic, strong) NSString *lastImageUrlString;
@property (nonatomic, strong) NSImage *lastImage;

- (void)_loadImage;

@end

@implementation BSTrack

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _track = @"";
        _album = @"";
        _artist = @"";
        _favorited = @0;
        _image = nil;
    }
    return self;
}

- (instancetype)initWithInfo:(NSDictionary *)info
{
    self = [self init];
    if (self)
    {
        _track = info[kBSTrackNameTrack] ?: @"";
        _album = info[kBSTrackNameAlbum] ?: @"";
        _artist = info[kBSTrackNameArtist] ?: @"";
        _favorited = info[kBSTrackNameFavorited] ?: @0; // 0 could also be evaluated as @NO
        _image = nil;
        _imageURL = info[kBSTrackNameImage] ?: nil;

        [self _loadImage];
    }
    return self;
}

// TODO - Add image caching and async loading so this doesn't become a network bottleneck.
- (void)_loadImage
{
    if (!_imageURL)
        return;

    self.image = [self imageByUrlString:_imageURL];
}

- (NSUserNotification *)asNotification
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];

    notification.title = self.track;
    notification.subtitle = self.album;
    notification.informativeText = self.artist;

    if (self.favorited && [self.favorited boolValue]) {

        if (notification.title) {
            notification.title = [NSString stringWithFormat:@"★ %@ ★", notification.title];
        }
        else if (notification.subtitle){
            notification.subtitle = [NSString stringWithFormat:@"★ %@ ★", notification.subtitle];
        }
        else if (notification.informativeText){

            notification.informativeText = [NSString stringWithFormat:@"★ %@ ★", notification.informativeText];
        }
    }

    if (self.image && [self.image isKindOfClass:[NSImage class]]) {
        // workaround for 10.8 support
        if ([notification respondsToSelector:@selector(setContentImage:)]) {
        //
            notification.contentImage = self.image;
        }
    }
    return notification;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key { /* Do nothing. */ }

// TODO make this thread and cache safe. PINCache for osx?
- (NSImage *)imageByUrlString:(NSString *)urlString
{
    if (!urlString)
        return nil;

    if (![urlString isEqualToString:_lastImageUrlString])
    {
        _lastImageUrlString = urlString;
        NSURL *url = [NSURL URLWithString:urlString];
        if (url)
        {
            if (!url.scheme)
                url = [NSURL URLWithString:[NSString stringWithFormat:@"http:%@", urlString]];

            self.lastImage = [[NSImage alloc] initWithContentsOfURL:url];
        }
        else
            self.lastImage = nil;
    }

    return _lastImage;
}

@end
