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
  toggle: function () {return window.Grooveshark.togglePlayPause()},
  next: function () { playNextSong(0); },
  favorite: function () {return window.Grooveshark.favoriteCurrentSong()},
  previous: function () { playBackSong(); },
  pause: function () { pause(); },
  trackInfo: function () {
    var data = window.Grooveshark.getCurrentSongStatus()["song"];
    return {
      'track': data["songName"],
      'album': data["albumName"],
      'artist': data["artistName"],
    }
  }
}
