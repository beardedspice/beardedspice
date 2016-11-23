//
//  BandCamp.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"BandCampWhiteLabel",
  accepts: {
    method: "script",
    script: function () {
      return (RegExp("https?://bandcamp\.com").test(siteroot));
    }
  },
  toggle: function () {gplaylist.playpause()},
  next: function () {gplaylist.next_track()},
  previous: function () {gplaylist.prev_track()},
  pause: function () {gplaylist.pause()},
  trackInfo: function () {
    return {
      'artist': EmbedData.artist,
      'album': EmbedData.album_title,
      'track': gplaylist.get_track_info().title
    }
  }
}
