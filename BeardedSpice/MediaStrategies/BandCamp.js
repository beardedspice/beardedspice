//
//  BandCamp.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"BandCamp",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*bandcamp.com*'",
    args: ["URL"]
  },
  toggle: function () {gplaylist.playpause()},
  next: function () {gplaylist.next_track()},
  previous: function () {gplaylist.prev_track()},
  pause: function () {gplaylist.pause()},
  trackInfo: function () {
    return {
      'artist': EmbedData.artist,
      'album': EmbedData.album_title,
      'track': gplaylist.get_track_info().title,
      'image': document.getElementById('tralbumArt').children[0].href,
      'progress': document.getElementsByClassName("time_elapsed")[0].innerText + " / " + document.getElementsByClassName("time_total")[0].innerText
    }
  }
}
