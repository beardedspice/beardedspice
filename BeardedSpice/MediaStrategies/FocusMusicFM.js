//
//  FocusMusicFM.js
//  BeardedSpice
//
//  Created by Adam Albrecht on 10/19/2016
//  Copyright (c) 2016 Bearded Spice. All rights reserved.
// OR
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "focusmusic.fm",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*focusmusic.fm*'",
    args: ["URL"]
  },

  isPlaying: function () { return document.querySelector(".fa-play-circle").classList.contains('hidden'); },
  toggle: function () {
    if (document.querySelector(".fa-play-circle").classList.contains('hidden')) {
      document.querySelector(".fa-pause-circle").click();
    } else {
      document.querySelector(".fa-play-circle").click();
    }
  },
  previous: function () {
    document.querySelector(".controls.previous").click();
  },
  next: function () { 
    document.querySelector(".controls.next").click();
  },
  pause: function () {
    document.querySelector(".fa-pause-circle").click();
  },
  favorite: function () { /* toggles favorite on/off */},
  trackInfo: function () {
    return {
        'track': document.querySelector(".track-title").innerText,
        'artist': document.querySelector(".artist").innerText
    };
  }
}

