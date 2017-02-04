//
//  NPROne.js
//  BeardedSpice
//
//  Created by Alex Evers on 1/27/2017.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "NPR One",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*one.npr.org*'",
    args: ["URL"]
  },

  isPlaying: function () { return !$('audio')[0].paused; },
  toggle:    function () {
    var audio = $('audio')[0];
    if (audio.paused) {
      audio.play();
    } else {
      audio.pause();
    }
  },
  previous:  function () { $('rewind button').click(); },
  next:      function () { $('skip button').click(); },
  pause:     function () { $('audio')[0].pause() },
  favorite:  function () {},

  trackInfo: function () {
    var audio = $('audio')[0];
    return {
        'track': $('.card__title:first').text(),
        'artist': 'NPR One'
    };
  }
}
