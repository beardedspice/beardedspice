/*
 * Downcast.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class DowncastApplication, DowncastNowPlayingInfo;



/*
 * Downcast Script Suite
 */

// The application's top-level scripting object.
@interface DowncastApplication : SBApplication

@property (copy, readonly) DowncastNowPlayingInfo *nowPlayingInfo;

- (void) playpause;  // Toggles play/pause state. Pauses if currently playing, plays if currently paused
- (void) play;  // Plays if currently paused
- (void) pause;  // Pauses if currently playing
- (void) next;
- (void) previous;

@end

@interface DowncastNowPlayingInfo : SBObject

@property (copy, readonly) NSString *episodeTitle;
@property (copy, readonly) NSString *sourceTitle;  // The title of the podcast or playlist this episode is being played from.
@property NSInteger duration;
@property NSInteger playPosition;
@property (copy, readonly) NSString *mediaURL;
@property (copy, readonly) NSString *publisher;
@property (copy, readonly) NSData *artworkData;
@property (readonly) BOOL isPlaying;


@end

