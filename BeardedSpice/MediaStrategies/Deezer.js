//
//  Deezer.plist
//  BeardedSpice
//
//  Created by Greg Woodcock on 06/01/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

BSStrategy = {
  version: 3,
  displayName: "Deezer",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*deezer.com*'",
    args: ["URL"]
  },
  isPlaying: function() {
    return document.querySelector('.control-play .svg-icon').classList.contains('svg-icon-pause');
  },
  toggle: function () {
    document.querySelector('.control-play').click();
  },
  next: function () {
    document.querySelector('.control-next').click();
  },
  favorite: function (){
    document.querySelector('.player-actions button .svg-icon-love-outline').parentElement.click();
  },
  previous: function () {
    document.querySelector('.control-prev').click();
  },
  pause: function () {
    if (document.querySelector('.control-play .svg-icon').classList.contains('svg-icon-pause')) {
      document.querySelector('.control-play').click();
    }
  },
  trackInfo: function () {
    return {
      "track": document.querySelector('#player-cover .player-track-title .player-track-link').innerText,
      "artist": document.querySelector('#player-cover .player-track-artist .player-track-link').innerText,
      "image": document.querySelector('#player-cover img').src,
      "favorited": document.querySelector('.player-actions button .svg-icon-love-outline').classList.contains('is-active')
    };
  }
}
