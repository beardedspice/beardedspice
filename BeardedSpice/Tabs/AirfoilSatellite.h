/*
 * AirfoilSatellite.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class AirfoilSatelliteApplication, AirfoilSatelliteDocument, AirfoilSatelliteWindow, AirfoilSatelliteApplication;

enum AirfoilSatelliteSaveOptions {
	AirfoilSatelliteSaveOptionsYes = 'yes ' /* Save the file. */,
	AirfoilSatelliteSaveOptionsNo = 'no  ' /* Do not save the file. */,
	AirfoilSatelliteSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum AirfoilSatelliteSaveOptions AirfoilSatelliteSaveOptions;

enum AirfoilSatellitePrintingErrorHandling {
	AirfoilSatellitePrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	AirfoilSatellitePrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum AirfoilSatellitePrintingErrorHandling AirfoilSatellitePrintingErrorHandling;

@protocol AirfoilSatelliteGenericMethods

- (void) closeSaving:(AirfoilSatelliteSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
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
@interface AirfoilSatelliteApplication : SBApplication

- (SBElementArray<AirfoilSatelliteDocument *> *) documents;
- (SBElementArray<AirfoilSatelliteWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(AirfoilSatelliteSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) playpause;  // Request the source to toggle between playing and paused, if possible.
- (void) next;  // Request the source to play the next track, if possible.
- (void) previous;  // Request the source to play the previous track, if possible.

@end

// A document.
@interface AirfoilSatelliteDocument : SBObject <AirfoilSatelliteGenericMethods>

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.


@end

// A window.
@interface AirfoilSatelliteWindow : SBObject <AirfoilSatelliteGenericMethods>

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
@property (copy, readonly) AirfoilSatelliteDocument *document;  // The document whose contents are displayed in the window.


@end



/*
 * Airfoil Satellite Suite
 */

// The application's top-level scripting object.
@interface AirfoilSatelliteApplication (AirfoilSatelliteSuite)

@property (copy, readonly) NSString *trackTitle;  // Currently playing track title, if available
@property (copy, readonly) NSString *artist;  // Currently playing artist name, if available
@property (copy, readonly) NSString *album;  // Currently playing album name, if available
@property (copy, readonly) NSData *artwork;  // Currently playing artwork image, if avaliable

@end

