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
  toggle: function () {
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
  next: function () { __getMusicFlash().lcNext() },
  previous: function () { __getMusicFlash().lcPrev() },
  pause: function () { __getMusicFlash().lcPause(); },
  trackInfo: function () {
    return {
      'track': document.querySelector('#mmpcw .mus_player_song').firstChild.nodeValue,
      'artist': document.querySelector('#mmpcw .mus_player_artist').firstChild.nodeValue
    };
  }
}
