//
//  PlayerFM.js
//  BeardedSpice
//
//  Created by Lukasz Chojnowski on 1 May 2019.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

// We put the copyright inside the plist to retain consistent syntax coloring.

// Use a syntax checker to ensure validity. One is provided by nodejs (`node -c filename.js`)
// Normal formatting is supported (can copy/paste with newlines and indentations)

BSStrategy = {
  version: 1,
  displayName: "Player FM",
  accepts: {
    method: "predicateOnTab" /* OR "script" */,
    /* Use these if "predicateOnTab" */
    format: "%K LIKE[c] '*player.fm*'",
    args: ["URL" /* OR "title" */]
    /* Use "script" if method is "script" */
    /* [ex] script: "some javascript here that returns a boolean value" */
  },

  isPlaying: function () { return document.querySelector('.miniplayer.episode.populated-selections.paused') === null },
  toggle:    function () {
    if (document.querySelector('.miniplayer.episode.populated-selections.paused') === null) {
      document.querySelector('.control.pause').click();
    } else {
      document.querySelector('.control.play').click();
    }
  },
  previous:  function () { document.querySelector('.control.fast-backward').click(); },
  next:      function () { document.querySelector('.control.fast-forward').click(); },
  pause:     function () { document.querySelector('.control.pause').click() },
  favorite:  function () { /* toggles favorite on/off */},
  /*
  - Return a dictionary of namespaced key/values here.
  All manipulation should be supported in javascript.

  - Namespaced keys currently supported include: track, album, artist, favorited, image (URL)
  */
  trackInfo: function () {
    return {
        'track': document.querySelector('a.current-series-link').innerText,
        'album': document.querySelector('a.current-episode-link').innerText,
        'image': document.querySelector('a.thumb img').getAttribute('src')
    };
  }
}
// The file must have an empty line at the end.
