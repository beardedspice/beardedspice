//
//  KCRW.js
//  BeardedSpice
//
//  Created by Alan Ramos on 5/20/2016.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "KCRW",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*kcrw.com*'",
    args: ["URL"]
  },

  isPlaying: function () { return document.querySelector('#player_start_stop').classList.contains('active'); },
  toggle:    function () { return document.querySelectorAll('#player_start_stop')[0].click() },
  previous:  function () { return document.querySelectorAll('#player_back')[0].click() },
  next:      function () { return document.querySelectorAll('#player_fwd')[0].click() },
  pause:     function () { return document.querySelectorAll('#player_start_stop')[0].click() },
  favorite:  function () { /* toggles favorite on/off */ },
  trackInfo: function () {
    var meta = document.querySelector('a.playbackSoundBadge__title.sc-truncate');
    return {
      'track': document.querySelector('#player_subtitle>em').innerText.replace(/['"]+/g, ''),
      'artist': document.getElementById("player_subtitle").childNodes[0],
      'album': document.querySelector('#player_main_title').innerText
    };
  }
}
