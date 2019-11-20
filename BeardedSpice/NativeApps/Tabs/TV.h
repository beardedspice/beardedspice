/*
 * TV.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class TVApplication, TVItem, TVArtwork, TVPlaylist, TVLibraryPlaylist, TVSource, TVTrack, TVFileTrack, TVSharedTrack, TVURLTrack, TVUserPlaylist, TVFolderPlaylist, TVWindow, TVBrowserWindow, TVPlaylistWindow, TVVideoWindow;

enum TVEPlS {
	TVEPlSStopped = 'kPSS',
	TVEPlSPlaying = 'kPSP',
	TVEPlSPaused = 'kPSp',
	TVEPlSFastForwarding = 'kPSF',
	TVEPlSRewinding = 'kPSR'
};
typedef enum TVEPlS TVEPlS;

enum TVESrc {
	TVESrcLibrary = 'kLib',
	TVESrcSharedLibrary = 'kShd',
	TVESrcITunesStore = 'kITS',
	TVESrcUnknown = 'kUnk'
};
typedef enum TVESrc TVESrc;

enum TVESrA {
	TVESrAAlbums = 'kSrL' /* albums only */,
	TVESrAAll = 'kAll' /* all text fields */,
	TVESrAArtists = 'kSrR' /* artists only */,
	TVESrADisplayed = 'kSrV' /* visible text fields */,
	TVESrANames = 'kSrS' /* track names only */
};
typedef enum TVESrA TVESrA;

enum TVESpK {
	TVESpKNone = 'kNon',
	TVESpKFolder = 'kSpF',
	TVESpKLibrary = 'kSpL',
	TVESpKMovies = 'kSpI',
	TVESpKTVShows = 'kSpT'
};
typedef enum TVESpK TVESpK;

enum TVEMdK {
	TVEMdKHomeVideo = 'kVdH' /* home video track */,
	TVEMdKMovie = 'kVdM' /* movie track */,
	TVEMdKTVShow = 'kVdT' /* TV show track */,
	TVEMdKUnknown = 'kUnk'
};
typedef enum TVEMdK TVEMdK;

enum TVERtK {
	TVERtKUser = 'kRtU' /* user-specified rating */,
	TVERtKComputed = 'kRtC' /* computed rating */
};
typedef enum TVERtK TVERtK;

@protocol TVGenericMethods

- (void) close;  // Close an object
- (void) delete;  // Delete an element from an object
- (SBObject *) duplicateTo:(SBObject *)to;  // Duplicate one or more object(s)
- (BOOL) exists;  // Verify if an object exists
- (void) open;  // Open the specified object(s)
- (void) save;  // Save the specified object(s)
- (void) playOnce:(BOOL)once;  // play the current track or the specified track or file.
- (void) select;  // select the specified object(s)

@end



/*
 * TV Suite
 */

// The application program
@interface TVApplication : SBApplication

- (SBElementArray<TVBrowserWindow *> *) browserWindows;
- (SBElementArray<TVPlaylist *> *) playlists;
- (SBElementArray<TVPlaylistWindow *> *) playlistWindows;
- (SBElementArray<TVSource *> *) sources;
- (SBElementArray<TVTrack *> *) tracks;
- (SBElementArray<TVVideoWindow *> *) videoWindows;
- (SBElementArray<TVWindow *> *) windows;

@property (copy, readonly) TVPlaylist *currentPlaylist;  // the playlist containing the currently targeted track
@property (copy, readonly) NSString *currentStreamTitle;  // the name of the current track in the playing stream (provided by streaming server)
@property (copy, readonly) NSString *currentStreamURL;  // the URL of the playing stream or streaming web site (provided by streaming server)
@property (copy, readonly) TVTrack *currentTrack;  // the current targeted track
@property BOOL fixedIndexing;  // true if all AppleScript track indices should be independent of the play order of the owning playlist.
@property BOOL frontmost;  // is this the active application?
@property BOOL fullScreen;  // is the application using the entire screen?
@property (copy, readonly) NSString *name;  // the name of the application
@property BOOL mute;  // has the sound output been muted?
@property double playerPosition;  // the player’s position within the currently playing track in seconds.
@property (readonly) TVEPlS playerState;  // is the player stopped, paused, or playing?
@property (copy, readonly) SBObject *selection;  // the selection visible to the user
@property NSInteger soundVolume;  // the sound output volume (0 = minimum, 100 = maximum)
@property (copy, readonly) NSString *version;  // the version of the application

- (void) run;  // Run the application
- (void) quit;  // Quit the application
- (TVTrack *) add:(NSArray<NSURL *> *)x to:(SBObject *)to;  // add one or more files to a playlist
- (void) backTrack;  // reposition to beginning of current track or go to previous track if already at start of current track
- (TVTrack *) convert:(NSArray<SBObject *> *)x;  // convert one or more files or tracks
- (void) fastForward;  // skip forward in a playing track
- (void) nextTrack;  // advance to the next track in the current playlist
- (void) pause;  // pause playback
- (void) playOnce:(BOOL)once;  // play the current track or the specified track or file.
- (void) playpause;  // toggle the playing/paused state of the current track
- (void) previousTrack;  // return to the previous track in the current playlist
- (void) resume;  // disable fast forward/rewind and resume playback, if playing.
- (void) rewind;  // skip backwards in a playing track
- (void) stop;  // stop playback
- (void) openLocation:(NSString *)x;  // Opens an iTunes Store or stream URL

@end

// an item
@interface TVItem : SBObject <TVGenericMethods>

@property (copy, readonly) SBObject *container;  // the container of the item
- (NSInteger) id;  // the id of the item
@property (readonly) NSInteger index;  // the index of the item in internal application order
@property (copy) NSString *name;  // the name of the item
@property (copy, readonly) NSString *persistentID;  // the id of the item as a hexadecimal string. This id does not change over time.
@property (copy) NSDictionary *properties;  // every property of the item

- (void) download;  // download a cloud track or playlist
- (void) reveal;  // reveal and select a track or playlist

@end

// a piece of art within a track or playlist
@interface TVArtwork : TVItem

@property (copy) NSImage *data;  // data for this artwork, in the form of a picture
@property (copy) NSString *objectDescription;  // description of artwork as a string
@property (readonly) BOOL downloaded;  // was this artwork downloaded by iTunes?
@property (copy, readonly) NSNumber *format;  // the data format for this piece of artwork
@property NSInteger kind;  // kind or purpose of this piece of artwork
@property (copy) id rawData;  // data for this artwork, in original format


@end

// a list of tracks/streams
@interface TVPlaylist : TVItem

- (SBElementArray<TVTrack *> *) tracks;
- (SBElementArray<TVArtwork *> *) artworks;

@property (copy) NSString *objectDescription;  // the description of the playlist
@property (readonly) NSInteger duration;  // the total length of all tracks (in seconds)
@property (copy) NSString *name;  // the name of the playlist
@property (copy, readonly) TVPlaylist *parent;  // folder which contains this playlist (if any)
@property (readonly) NSInteger size;  // the total size of all tracks (in bytes)
@property (readonly) TVESpK specialKind;  // special playlist kind
@property (copy, readonly) NSString *time;  // the length of all tracks in MM:SS format
@property (readonly) BOOL visible;  // is this playlist visible in the Source list?

- (void) moveTo:(SBObject *)to;  // Move playlist(s) to a new location
- (TVTrack *) searchFor:(NSString *)for_ only:(TVESrA)only;  // search a playlist for tracks matching the search string. Identical to entering search text in the Search field.

@end

// the master library playlist
@interface TVLibraryPlaylist : TVPlaylist

- (SBElementArray<TVFileTrack *> *) fileTracks;
- (SBElementArray<TVURLTrack *> *) URLTracks;
- (SBElementArray<TVSharedTrack *> *) sharedTracks;


@end

// a media source (library, CD, device, etc.)
@interface TVSource : TVItem

- (SBElementArray<TVLibraryPlaylist *> *) libraryPlaylists;
- (SBElementArray<TVPlaylist *> *) playlists;
- (SBElementArray<TVUserPlaylist *> *) userPlaylists;

@property (readonly) long long capacity;  // the total size of the source if it has a fixed size
@property (readonly) long long freeSpace;  // the free space on the source if it has a fixed size
@property (readonly) TVESrc kind;


@end

// playable video source
@interface TVTrack : TVItem

- (SBElementArray<TVArtwork *> *) artworks;

@property (copy) NSString *album;  // the album name of the track
@property NSInteger albumRating;  // the rating of the album for this track (0 to 100)
@property (readonly) TVERtK albumRatingKind;  // the rating kind of the album rating for this track
@property (readonly) NSInteger bitRate;  // the bit rate of the track (in kbps)
@property double bookmark;  // the bookmark time of the track in seconds
@property BOOL bookmarkable;  // is the playback position for this track remembered?
@property (copy) NSString *category;  // the category of the track
@property (copy) NSString *comment;  // freeform notes about the track
@property (readonly) NSInteger databaseID;  // the common, unique ID for this track. If two tracks in different playlists have the same database ID, they are sharing the same data.
@property (copy, readonly) NSDate *dateAdded;  // the date the track was added to the playlist
@property (copy) NSString *objectDescription;  // the description of the track
@property (copy) NSString *director;  // the artist/source of the track
@property NSInteger discCount;  // the total number of discs in the source album
@property NSInteger discNumber;  // the index of the disc containing this track on the source album
@property (copy, readonly) NSString *downloaderAppleID;  // the Apple ID of the person who downloaded this track
@property (copy, readonly) NSString *downloaderName;  // the name of the person who downloaded this track
@property (readonly) double duration;  // the length of the track in seconds
@property BOOL enabled;  // is this track checked for playback?
@property (copy) NSString *episodeID;  // the episode ID of the track
@property NSInteger episodeNumber;  // the episode number of the track
@property double finish;  // the stop time of the track in seconds
@property (copy) NSString *genre;  // the genre (category) of the track
@property (copy) NSString *grouping;  // the grouping (piece) of the track. Generally used to denote movements within a classical work.
@property (copy, readonly) NSString *kind;  // a text description of the track
@property (copy) NSString *longDescription;  // the long description of the track
@property TVEMdK mediaKind;  // the media kind of the track
@property (copy, readonly) NSDate *modificationDate;  // the modification date of the content of this track
@property NSInteger playedCount;  // number of times this track has been played
@property (copy) NSDate *playedDate;  // the date and time this track was last played
@property (copy, readonly) NSString *purchaserAppleID;  // the Apple ID of the person who purchased this track
@property (copy, readonly) NSString *purchaserName;  // the name of the person who purchased this track
@property NSInteger rating;  // the rating of this track (0 to 100)
@property (readonly) TVERtK ratingKind;  // the rating kind of this track
@property (copy, readonly) NSDate *releaseDate;  // the release date of this track
@property (readonly) NSInteger sampleRate;  // the sample rate of the track (in Hz)
@property NSInteger seasonNumber;  // the season number of the track
@property NSInteger skippedCount;  // number of times this track has been skipped
@property (copy) NSDate *skippedDate;  // the date and time this track was last skipped
@property (copy) NSString *show;  // the show name of the track
@property (copy) NSString *sortAlbum;  // override string to use for the track when sorting by album
@property (copy) NSString *sortDirector;  // override string to use for the track when sorting by artist
@property (copy) NSString *sortName;  // override string to use for the track when sorting by name
@property (copy) NSString *sortShow;  // override string to use for the track when sorting by show name
@property (readonly) long long size;  // the size of the track (in bytes)
@property double start;  // the start time of the track in seconds
@property (copy, readonly) NSString *time;  // the length of the track in MM:SS format
@property NSInteger trackCount;  // the total number of tracks on the source album
@property NSInteger trackNumber;  // the index of the track on the source album
@property BOOL unplayed;  // is this track unplayed?
@property NSInteger volumeAdjustment;  // relative volume adjustment of the track (-100% to 100%)
@property NSInteger year;  // the year the track was recorded/released


@end

// a track representing a video file
@interface TVFileTrack : TVTrack

@property (copy) NSURL *location;  // the location of the file represented by this track

- (void) refresh;  // update file track information from the current information in the track’s file

@end

// a track residing in a shared library
@interface TVSharedTrack : TVTrack


@end

// a track representing a network stream
@interface TVURLTrack : TVTrack

@property (copy) NSString *address;  // the URL for this track


@end

// custom playlists created by the user
@interface TVUserPlaylist : TVPlaylist

- (SBElementArray<TVFileTrack *> *) fileTracks;
- (SBElementArray<TVURLTrack *> *) URLTracks;
- (SBElementArray<TVSharedTrack *> *) sharedTracks;

@property BOOL shared;  // is this playlist shared?
@property (readonly) BOOL smart;  // is this a Smart Playlist?


@end

// a folder that contains other playlists
@interface TVFolderPlaylist : TVUserPlaylist


@end

// any window
@interface TVWindow : TVItem

@property NSRect bounds;  // the boundary rectangle for the window
@property (readonly) BOOL closeable;  // does the window have a close button?
@property (readonly) BOOL collapseable;  // does the window have a collapse button?
@property BOOL collapsed;  // is the window collapsed?
@property BOOL fullScreen;  // is the window full screen?
@property NSPoint position;  // the upper left position of the window
@property (readonly) BOOL resizable;  // is the window resizable?
@property BOOL visible;  // is the window visible?
@property (readonly) BOOL zoomable;  // is the window zoomable?
@property BOOL zoomed;  // is the window zoomed?


@end

// the main window
@interface TVBrowserWindow : TVWindow

@property (copy, readonly) SBObject *selection;  // the selected tracks
@property (copy) TVPlaylist *view;  // the playlist currently displayed in the window


@end

// a sub-window showing a single playlist
@interface TVPlaylistWindow : TVWindow

@property (copy, readonly) SBObject *selection;  // the selected tracks
@property (copy, readonly) TVPlaylist *view;  // the playlist displayed in the window


@end

// the video window
@interface TVVideoWindow : TVWindow


@end

