//
//  BSStrategyVersionManager.m
//  BeardedSpice
//
//  Created by Alex Evers on 12/01/15.
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

#import <XCTest/XCTest.h>
#import "BSTrack.h"

@interface BSTrackTests : XCTestCase

@end

@implementation BSTrackTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNewTrack
{
    BSTrack *track = [BSTrack new];
    XCTAssertTrue(track.track != nil, "Default track value is not empty string!");
    XCTAssertTrue(track.album != nil, "Default album value is not empty string!");
    XCTAssertTrue(track.artist != nil, "Default artist value is not empty string!");
    XCTAssertTrue(track.favorited != nil, "Default favorited value is not @0!");
    XCTAssertTrue(track.image == nil, "Default image value is not nil!");
}

- (void)testDirectAssignment
{
    BSTrack *track = [BSTrack new];
    track.track = @"a test track value";
    XCTAssertTrue(track.track != nil, "Direct Assignment track value is nil!");
    XCTAssertTrue(track.track.length > 0, "Direct Assignment track value is empty!");

    track.album = @"a test album value";
    XCTAssertTrue(track.album != nil, "Direct Assignment album value is nil!");
    XCTAssertTrue(track.album.length > 0, "Direct Assignment album value is empty!");

    track.artist = @"a test artist value";
    XCTAssertTrue(track.artist != nil, "Direct Assignment artist value is nil!");
    XCTAssertTrue(track.artist.length > 0, "Direct Assignment artist value is empty!");

    track.favorited = @1;
    XCTAssertTrue(track.favorited != nil, "Direct Assignment favorited value is nil!");
    // be careful with BOOL vs bool vs boolean typecasting here.
    // We expect a BOOL from NSNumber so we compare to YES/NO
    XCTAssertTrue([track.favorited boolValue] == YES, "Direct Assignment favorited value is NO!");

    track.image = [NSImage new];
    XCTAssertTrue(track.image != nil, "Direct Assignment image value is nil!");
}

- (void)testWithInfo
{
    BSTrack *track = [[BSTrack alloc] initWithInfo:@{
        kBSTrackNameTrack: @"a test track value",
        kBSTrackNameAlbum: @"a test album value",
        kBSTrackNameArtist: @"a test artist value",
        kBSTrackNameFavorited: @1,
    }];

    XCTAssertTrue(track.track != nil, "Assignment to track value via constructor is nil!");
    XCTAssertTrue(track.track.length > 0, "Assignment to track value via constructor is empty!");

    XCTAssertTrue(track.album != nil, "Assignment to album value via constructor is nil!");
    XCTAssertTrue(track.album.length > 0, "Assignment to album value via constructor is empty!");

    XCTAssertTrue(track.artist != nil, "Assignment to artist value via constructor is nil!");
    XCTAssertTrue(track.artist.length > 0, "Assignment to artist value via constructor is empty!");

    XCTAssertTrue(track.favorited != nil, "Assignment to favorited value via constructor is nil!");
    // be careful with BOOL vs bool vs boolean typecasting here.
    // We expect a BOOL from NSNumber so we compare to YES/NO
    XCTAssertTrue([track.favorited boolValue] == YES, "Assignment to favorited value via constructor is NO!");
}

- (void)testImageLoading
{
    // TODO FIXME when we properly finish the image loading components
}

@end
