/*
 * Fluid.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class FluidApplication, FluidDocument, FluidWindow, FluidBrowserWindow, FluidTab;

enum FluidSaveOptions {
	FluidSaveOptionsYes = 'yes ' /* Save the file. */,
	FluidSaveOptionsNo = 'no  ' /* Do not save the file. */,
	FluidSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum FluidSaveOptions FluidSaveOptions;

enum FluidPrintingErrorHandling {
	FluidPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	FluidPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum FluidPrintingErrorHandling FluidPrintingErrorHandling;

enum FluidCaptureOptions {
	FluidCaptureOptionsScreenshot = 'Scrn' /* Capture the web page as a screenshot. */,
	FluidCaptureOptionsWebArchive = 'WbAr' /* Capture the web page as a Web Archive document. */,
	FluidCaptureOptionsRawSource = 'Src ' /* Capture the web page as a raw source. */
};
typedef enum FluidCaptureOptions FluidCaptureOptions;



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface FluidApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) browserWindows;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(FluidSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) emptyCache;  // Empty the browser's cache.
- (void) loadURL:(NSString *)x in:(FluidTab *)in_;  // Load a URL.
- (id) doJavaScript:(NSString *)x in:(FluidTab *)in_;  // Applies a string of JavaScript code to a document.
- (void) captureWebPageAs:(FluidCaptureOptions)as savingIn:(NSURL *)savingIn in:(FluidTab *)in_;  // Capture this tab's web page as a screenshot, Web Archive or raw source.
- (void) goBack;  // Go back.
- (void) goForward;  // Go forward.
- (void) goHome;  // Go home.
- (void) reload;  // Reload a web page.
- (void) stopLoading;  // Stop loading a web page.
- (void) zoomIn;  // Zoom in contents of the page.
- (void) zoomOut;  // Zoom out contents of the page.
- (void) showActualSize;  // Zoom contents of the page to actual size.

@end

// A document.
@interface FluidDocument : SBObject

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.

- (void) closeSaving:(FluidSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) goBack;  // Go back.
- (void) goForward;  // Go forward.
- (void) goHome;  // Go home.
- (void) reload;  // Reload a web page.
- (void) stopLoading;  // Stop loading a web page.
- (void) zoomIn;  // Zoom in contents of the page.
- (void) zoomOut;  // Zoom out contents of the page.
- (void) showActualSize;  // Zoom contents of the page to actual size.

@end

// A window.
@interface FluidWindow : SBObject

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
@property (copy, readonly) FluidDocument *document;  // The document whose contents are displayed in the window.

- (void) closeSaving:(FluidSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) goBack;  // Go back.
- (void) goForward;  // Go forward.
- (void) goHome;  // Go home.
- (void) reload;  // Reload a web page.
- (void) stopLoading;  // Stop loading a web page.
- (void) zoomIn;  // Zoom in contents of the page.
- (void) zoomOut;  // Zoom out contents of the page.
- (void) showActualSize;  // Zoom contents of the page to actual size.

@end



/*
 * Fluid App Suite
 */

// A browser window.
@interface FluidBrowserWindow : FluidDocument

- (SBElementArray *) tabs;

@property (copy, readonly) NSString *title;  // The current title of the web page currently loaded in this window (same as the title of the selected tab in this window).
@property (copy, readonly) NSString *URL;  // The URL of the web page currently loaded in this tab (same as the URL of the selected tab in this window).
@property (readonly) BOOL loading;  // True if this window's web page is currently loading. Otherwise false. (same as the loading property of the selected tab in this window).
@property (copy, readonly) NSString *source;  // The HTML source of the web page currently loaded in this window (same as the source of the selected tab in this window).
@property (copy) FluidTab *selectedTab;  // The selected tab in this window.


@end

// A browser tab.
@interface FluidTab : SBObject

@property (readonly) NSInteger index;  // The index of this tab in its window.
@property (copy, readonly) NSString *title;  // The title of the web page currently loaded in this tab.
@property (copy, readonly) NSString *URL;  // The URL of the web page currently loaded in this tab.
@property (readonly) BOOL loading;  // True if this tab's web page is currently loading. Otherwise false.
@property (readonly) BOOL selected;  // True if this is the selected tab in its window. Otherwise false.
@property (copy, readonly) NSString *source;  // The HTML source of the web page currently loaded in this tab.

- (void) closeSaving:(FluidSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) goBack;  // Go back.
- (void) goForward;  // Go forward.
- (void) goHome;  // Go home.
- (void) reload;  // Reload a web page.
- (void) stopLoading;  // Stop loading a web page.
- (void) zoomIn;  // Zoom in contents of the page.
- (void) zoomOut;  // Zoom out contents of the page.
- (void) showActualSize;  // Zoom contents of the page to actual size.

@end

