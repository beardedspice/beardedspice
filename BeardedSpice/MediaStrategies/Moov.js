//
//  Moov.plist
//  BeardedSpice
//
//  Created by Mickeo Leung on 10/15/16.
//  Copyright (c) 2016 Mickeo Leung. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName: "Moov",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*moov.hk*'",
    args: ["URL"]
  },
  isPlaying: function () { return !!~document.querySelector('#pause').className.indexOf('pause'); },
  toggle: function () {
      if (!!~document.querySelector('#pause').className.indexOf('pause')) {
          pauseItem && pauseItem();
      } else {
          playItem && playItem();
      };
  },
  previous: function () { playPrev && playPrev(); },
  next: function () { playNext && playNext(); },
  pause: function () { pauseItem && pauseItem(); },
  trackInfo: function () {
    return {
      'image': document.querySelector('#thumbnail').querySelector('img').src,
      'track': document.querySelector('#player_info').querySelector('.song').innerText,
      'artist': document.querySelector('#player_info').querySelector('.artist').innerText
    };
  }
}
