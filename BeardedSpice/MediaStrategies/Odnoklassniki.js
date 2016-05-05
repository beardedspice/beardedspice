//
//  Odnoklassniki.plist
//  BeardedSpice
//
//  Created by Alexander Chuprin on 2/16/2015.
//  Copyright (c) 2015 Alexander Chuprin. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Odnoklassniki",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*ok.ru*' OR SELF LIKE[c] '*odnoklassniki.ru*'",
    args:"url"
  },
  toggle: function toggle () {
    if (odklMusic.playingTrack() == "") {
      if (window['__getMusicFlash']) {
        __getMusicFlash().lcResume()
      } else {
        odklMusic.openAndLaunchMusicPlaying();
      }
    } else {
      __getMusicFlash().lcPause();
    }
  },
  next: function next () { __getMusicFlash().lcNext() },
  previous: function previous () { __getMusicFlash().lcPrev() },
  pause: function pause () { __getMusicFlash().lcPause(); },
  trackInfo: function trackInfo () {
    return {
      'track': document.querySelector('#mmpcw .mus_player_song').firstChild.nodeValue,
      'artist': document.querySelector('#mmpcw .mus_player_artist').firstChild.nodeValue
    };
  }
}
