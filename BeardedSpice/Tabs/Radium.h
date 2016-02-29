/*
 * Radium.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class RadiumApplication, RadiumApplication;



/*
 * Standard Suite
 */

// Radium's top level scripting object.
@interface RadiumApplication : SBApplication

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *version;  // The version of the application.

- (void) quit;  // Quit an application.
- (void) play;  // play/resume the currently-selected station
- (void) pause;  // pause playback
- (void) playpause;  // toggle Radium's playing/paused state
- (void) stop;  // stop playback and disconnect from station

@end



/*
 * Radium Suite
 */

// Radium's toplevel scripting object
@interface RadiumApplication (RadiumSuite)

@property (copy, readonly) NSString *trackName;  // currently playing track (or missing value)
@property (copy, readonly) NSImage *trackArtwork;  // current track artwork (or missing value)
@property (copy, readonly) NSString *stationName;  // currently playing station name (or missing value)
@property (readonly) BOOL playing;  // is Radium currently playing?

@end

