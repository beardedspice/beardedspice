//
//  YouTube.plist
//  BeardedSpice
//
//  Created by Jean Bertrand on 10/10/16.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "Fip",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*fipradio.fr/player*'",
    args: ["URL"]
  },
  isPlaying: function () { return (document.querySelector('#player-controls .stop') !== null); },
  toggle: function () { document.querySelector('#player-controls button').click();; },
  previous: function () { },
  next: function () { },
  pause: function () { document.querySelector('#player-controls button').click(); },
  trackInfo: function () {
    return {
      'image': document.querySelector('.cover .picture').getAttribute('src'),
      'track': document.querySelector('.infos .title').getAttribute('title'),
      'artist': document.querySelector('.infos .author .name').getAttribute('title')
    };
  }
}
