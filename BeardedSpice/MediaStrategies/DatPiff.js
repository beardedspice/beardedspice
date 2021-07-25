//
//  DatPiff.js
//  BeardedSpice
//
//  Created by Beau on 2017-07-08
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

// We put the copyright inside the plist to retain consistent syntax coloring.

// Use a syntax checker to ensure validity. One is provided by nodejs (`node -c filename.js`)
// Normal formatting is supported (can copy/paste with newlines and indentations)

// Caveats:
// This only works on the desktop version of DatPiff, with Flash disabled.
// Since that loads an iframe on a different domain, we need the bare iframe loaded in a tab.

BSStrategy = {
  version: 1,
  displayName: "DatPiff",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*mobile.datpiff.com/social/twitter/twitter-card.php*'",
    args: ["URL"],
  },

  isPlaying: function () {return document.querySelector('.isplay') !== null;},
  toggle:    function () {return document.querySelector('.play').click();},
  previous:  function () {return document.querySelector('.back').click();},
  next:      function () {return document.querySelector('.next').click();},
  pause:     function () {
      var isplay = document.querySelector('.isplay');
      if (isplay !== null) {
          isplay.click();
      }
  },
  favorite:  function () {},
  trackInfo: function () {
    return {
        'track': document.querySelector('.main-playing').innerText,
        'album': document.querySelector('.title').innerText,
        'artist': document.querySelector('.artist').innerText,
        'image': document.querySelector('div:nth-child(2) img').src,
    };
  }
};
// The file must have an empty line at the end.
