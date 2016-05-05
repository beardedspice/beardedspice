//
//  GrooveShark.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Grooveshark",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*grooveshark.im*'",
    args:"url"
  },
  toggle: function toggle () {return window.Grooveshark.togglePlayPause()},
  next: function next () { playNextSong(0); },
  favorite: function favorite () {return window.Grooveshark.favoriteCurrentSong()},
  previous: function previous () { playBackSong(); },
  pause: function pause () { pause(); },
  trackInfo: function trackInfo () {
    var data = window.Grooveshark.getCurrentSongStatus()["song"];
    return {
      'track': data["songName"],
      'album': data["albumName"],
      'artist': data["artistName"],
    }
  }
}
