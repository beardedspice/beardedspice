//
//  BandCamp.plist
//  BeardedSpice
//
//  Copied from BandCamp.js and editted by Jon Bramley on 23/11/2016.
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 2,
  displayName:"BandCampWhiteLabel",
  accepts: {
    method: "script",
    script: function () {
      return window.siteroot ? RegExp("https?://bandcamp\.com").test(window.siteroot) : false;
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
