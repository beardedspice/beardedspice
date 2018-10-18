//
//  Deezer.plist
//  BeardedSpice
//
//  Created by Greg Woodcock on 06/01/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//

BSStrategy = {
  version: 4,
  displayName: "Deezer",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*deezer.com*'",
    args: ["URL"]
  },
  isPlaying: function() {
    return document.querySelector('.player-controls svg-icon-group-btn.is-highlight .svg-icon').classList.contains('svg-icon-pause');
  },
  toggle: function () {
    document.querySelector('.player-controls .svg-icon-group-btn.is-highlight').click();
  },
  next: function () {
    document.querySelector('.player-controls .svg-icon-next').parentElement.click();
  },
  favorite: function (){
    document.querySelector('div.player-track .svg-icon-love-outline').parentElement.click();
  },
  previous: function () {
    document.querySelector('.player-controls .svg-icon-prev').parentElement.click();
  },
  pause: function () {
    if (document.querySelector('.player-controls svg-icon-group-btn.is-highlight .svg-icon').classList.contains('svg-icon-pause')) {
      document.querySelector('.player-controls .svg-icon-group-btn.is-highlight').click();
    }
  },
  trackInfo: function () {
    return {
      "track": document.querySelector('#player-cover .player-track-title .player-track-link').innerText,
      "artist": document.querySelector('#player-cover .player-track-artist .player-track-link').innerText,
      "image": document.querySelector('#player-cover img').src,
      "favorited": document.querySelector('.player-actions button .icon-love').classList.contains('active')
    };
  }
}
