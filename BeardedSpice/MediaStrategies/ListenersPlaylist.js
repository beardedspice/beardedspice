//
//  ListenersPlaylist.js
//  BeardedSpice
//
//  Created by Wojtek Witkowski (wojtek.im) on February 11, 2017.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Listeners Playlist (lp.anzi.kr)",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*lp.anzi.kr*'",
    args: ["URL"]
  },
  isPlaying: function () {
    document.querySelector('.svg_pause').getAttribute('style').indexOf('opacity: 1') > -1;
  },
  toggle: function () {
    if (document.querySelector('.svg_pause').getAttribute('style').indexOf('opacity: 1') > -1) {
      document.querySelector('.svg_pause').click();
    } else {
      document.querySelector('.svg_play').click();
    }
  },
  previous: function () {
    document.querySelector('.svg_prev').click();
  },
  next: function () {
    document.querySelector('.svg_next').click();
  },
  pause: function () {
    document.querySelector('.svg_pause').click();
  },
  trackInfo: function () {
    return {
      'track': document.querySelector('.mainthumb_wrapper .info .title').innerText,
      'artist': document.querySelector('.mainthumb_wrapper .info .artist').innerText,
    };
  }
}
