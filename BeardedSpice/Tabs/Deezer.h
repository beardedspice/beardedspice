/*
 * Deezer.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class DeezerApplication, DeezerDocument, DeezerWindow, DeezerApplication, DeezerTrack;

enum DeezerSaveOptions {
	DeezerSaveOptionsYes = 'yes ' /* Save the file. */,
	DeezerSaveOptionsNo = 'no  ' /* Do not save the file. */,
	DeezerSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum DeezerSaveOptions DeezerSaveOptions;

enum DeezerPrintingErrorHandling {
	DeezerPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	DeezerPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum DeezerPrintingErrorHandling DeezerPrintingErrorHandling;

enum DeezerEPlS {
	DeezerEPlSStopped = 'kPSS',
	DeezerEPlSPlaying = 'kPSP'
};
typedef enum DeezerEPlS DeezerEPlS;

enum DeezerELop {
	DeezerELopNone = 'kReN',
	DeezerELopSame = 'kReS',
	DeezerELopInfinite = 'kReI'
};
typedef enum DeezerELop DeezerELop;

@protocol DeezerGenericMethods

- (void) closeSaving:(DeezerSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(id)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface DeezerApplication : SBApplication

- (SBElementArray<DeezerDocument *> *) documents;
- (SBElementArray<DeezerWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(DeezerSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) playpause;  // Toggle playback between playing and paused.
- (void) play;  // Resume playback
- (void) pause;  // Pause playback
- (void) nextTrack;  // Play the next track.
- (void) previousTrack;  // Play the previous track.
- (void) playTrack:(NSString *)x id:(NSString *)id_;  // Start playback of a track with a given ID. May require internet collection if the track is not synced locally.

@end

// A document.
@interface DeezerDocument : SBObject <DeezerGenericMethods>

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.


@end

// A window.
@interface DeezerWindow : SBObject <DeezerGenericMethods>

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) DeezerDocument *document;  // The document whose contents are displayed in the window.


@end



/*
 * Deezer Suite
 */

// The application's top-level scripting object.
@interface DeezerApplication (DeezerSuite)

- (SBElementArray<DeezerTrack *> *) tracks;

@property (copy, readonly) DeezerTrack *loadedTrack;  // The loaded track. (As in a jukebox)
@property (readonly) DeezerEPlS playerState;  // Is Deezer stopped, paused, or playing?
@property double playerPosition;  // player position in the currently playing track in seconds. Note that you can't change player position for radios, Flow or advertisements
@property NSInteger outputVolume;  // The sound output volume (0 = minimum, 100 = maximum)
@property DeezerELop loop;  // Is repeating on or off?
@property BOOL shuffle;  // Is shuffling on or off?
@property (copy, readonly) NSData *cover;  // Cover for the currently playing track.

@end

// A Deezer track.
@interface DeezerTrack : SBObject <DeezerGenericMethods>

@property (copy, readonly) NSString *album;  // The album name of the track.
@property (copy, readonly) NSString *artist;  // The artist's name of the track.
@property (readonly) NSInteger bpm;  // The bpm of the track. (Is often 0)
@property (copy, readonly) NSString *coverUrl;  // The URL of the track's album cover
@property (readonly) NSInteger diskNumber;  // The disk number of the track.
@property (readonly) NSInteger duration;  // The length of the track in seconds.
@property (readonly) BOOL isReadable;  // is the track readable?
@property (copy) NSString *deezerUrl;  // The URL of the track.
@property (readonly) NSInteger positionInAlbum;  // The index of the track in its album.
@property (copy, readonly) NSString *title;  // The title of the track.
@property (copy, readonly) NSData *cover;  // The track's album cover. Will be nil if the track is not a local track.
- (NSString *) id;  // The ID of the item. Will always be a positive number for normal tracks and negative for personal tracks.


@end

