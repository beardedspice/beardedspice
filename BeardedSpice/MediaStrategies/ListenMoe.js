//
//  ListenMoe.plist
//  BeardedSpice
//
//  Created by nVitius on 05/24/2017.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "Listen.moe",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] 'https://listen.moe*'",
    args: ["URL"]
  },
  isPlaying: function () { return (document.querySelector('#pause') !== null); },
  toggle: function () { document.querySelector('.player-button').click(); },
  previous: function () { },
  next: function () { },
  pause: function () { document.querySelector('.player-button').click(); },
  trackInfo: function () {
    var titleText = document.querySelector('.title').innerText.split(/ - (.+)/);
    return {
      'image': null,
      'artist': titleText[0],
      'track': titleText[1]
    };
  }
};
