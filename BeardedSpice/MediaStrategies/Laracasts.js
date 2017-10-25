//
//  Laracasts.js
//  BeardedSpice
//
//  Created by nVitius on on 05/25/2017.
//
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Laracasts",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*laracasts.com*'",
    args: ["URL"]
  },

  isPlaying: function () { return document.querySelector('.vjs-play-control.vjs-playing') !== null; },
  toggle:    function () {
    document.querySelector('.vjs-play-control').click();
  },
  previous:  function () { /* switch to previous track if any */ },
  next:      function () { /* switch to next track if any */ },
  pause:     function () { document.querySelector('.vjs-play-control.vjs-playing').click(); },
  favorite:  function () { /* toggles favorite on/off */},
}
