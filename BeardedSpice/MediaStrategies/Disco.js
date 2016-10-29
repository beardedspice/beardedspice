//
//  Disco.js
//  BeardedSpice
//
//  Created by Colin Drake on 8/19/15.
//  Converted to js strategy by Alex Evers 10/29/2016.
//
//  Copyright (c) 2015-2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Disco",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*disco.io*'",
    args: ["URL"]
  },

  isPlaying: function () { /* javascript that returns a boolean */ },
  toggle:    function () { $('#play-button').click() },
  previous:  function () { $('#previous-button').click() },
  next:      function () { $('#next-button').click() },
  pause:     function () { $('#play-button').click() },
  favorite:  function () { /* toggles favorite on/off */},
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.

  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {
    return {
        'track': $('#current-track-title').text(),
        'artist': $('#current-track-artist').text()
    };
  }
}
// The file must have an empty line at the end.
