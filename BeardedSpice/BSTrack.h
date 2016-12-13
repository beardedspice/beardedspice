//
//  BSTrack.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

extern NSString *const kBSTrackNameImage;
extern NSString *const kBSTrackNameTrack;
extern NSString *const kBSTrackNameAlbum;
extern NSString *const kBSTrackNameArtist;
extern NSString *const kBSTrackNameFavorited;
extern NSString *const kBSTrackNameIdentifier;

@interface BSTrack : NSObject

@property (nonatomic, strong) NSString *track;
@property (nonatomic, strong) NSString *album;
@property (nonatomic, strong) NSString *artist;

@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSNumber *favorited;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *trackData;

/** Constructor for encapsulating Track object
	@param info A pre-calculated dictionary of values that directly correspond to property key names
		Includes validations
	@return A fully initialized and validated BSTrack object with all avalailable values, placeholders otherwise.
 */
- (instancetype)initWithInfo:(NSDictionary *)info;

- (NSUserNotification *)asNotification;

@end
