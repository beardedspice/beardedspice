//
//  BandCamp.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"BandCamp",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*bandcamp.com*'",
    args: "url"
  },
  toggle: function toggle () {gplaylist.playpause()},
  next: function next () {gplaylist.next_track()},
  previous: function previous () {gplaylist.prev_track()},
  pause: function pause () {gplaylist.pause()},
  trackInfo: function trackInfo () {
    return {
      'artist': EmbedData.artist,
      'album': EmbedData.album_title,
      'track': gplaylist.get_track_info().title
    }
  }
}
