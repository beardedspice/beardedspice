//
//  Zvooq.js
//  BeardedSpice
//
//  Created by Eugene Tataurov on 12/23/16.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Zvooq",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*zvooq.com*'",
    args: ["URL"]
  },
  isPlaying: function () { return !!document.querySelector('.topPanelPause'); },
  toggle: function () { document.querySelector('.topPanelPlay, .topPanelPause').click(); },
  previous: function () { document.querySelector('.topPanelRewind').click(); },
  next: function () { document.querySelector('.topPanelForward').click(); },
  pause: function () {
    var pauseButton = document.querySelector('.topPanelPause');
    if (pauseButton != null) {
      pauseButton.click();
    }
  },
  favorite: function () { document.querySelector('.topPanelTimeline-favorite .favorite').click(); },
  trackInfo: function () {
    return {
      'track': document.querySelector('.topPanelTimeline-intitleRelease').innerText,
      'artist': document.querySelector('.topPanelTimeline-intitleArtist').innerText,
      'favorited': !!document.querySelector('.topPanelTimeline-favorite .favorite_checked')
    };
  }
}
