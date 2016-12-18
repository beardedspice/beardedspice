//
//  IndieShuffle.plist
//  BeardedSpice
//
//  Created by David Davis on 2015-06-30.
//  Updated v2 by Alex Evers on 2016-12-18.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:2,
  displayName:"IndieShuffle",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*indieshuffle.com*'",
    args: ["URL"]
  },
  isPlaying:function () { !youtubePaused && sound.playing() },
  toggle: function () { togglePlayPause(); },
  next: function () { nextSong(); },
  previous: function () { previousSong(); },
  pause: function () { sound.pause() /* || FIXME (some kind of yt.pause) */},
  trackInfo: function () {
    var song = playerObj.currentSong;
    return {
      'image': song.artwork,
      'track': song.title,
      'artist': song.artist
  }
}
