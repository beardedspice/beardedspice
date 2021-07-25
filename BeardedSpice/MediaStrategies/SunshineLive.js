//
//  SunshineLive.js
//  BeardedSpice
//
//  Created by Simon Demming on 14th May 2018.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Sunshine Live",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*sunshine-live.de*'",
    args: ["URL"]
  },

  isPlaying: function () {
    var btn = document.querySelector('.streamplayer-button');
    return btn.classList.contains('active-stream');
  },
  toggle: function () {
    var btn = document.querySelector('.streamplayer-button');
    btn.click();
  },
  previous: function () { /* requires list of all stations */ },
  next: function () { /* requires list of all stations */ },
  pause: function () {
    var btn = document.querySelector('.streamplayer-button');
    if (btn.classList.contains('active-stream')) {
      btn.click();
    }
  },
  favorite: function () { /* there is no favorite functionality supported by the site */},
  trackInfo: function () {
    var trackTitle = document.querySelector('.streamplayer-title').innerText;
    var artistName = document.querySelector('.streamplayer-artist').innerText;
    var streamTitle = document.querySelector('.streamplayer-stream-title').innerText;
    return {
        'track': trackTitle,
        'album': streamTitle,
        'artist': artistName,
    };
  }
}
