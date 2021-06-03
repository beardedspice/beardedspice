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
    return !!document.querySelector('.player-controls .svg-icon-pause');
  },
  toggle: function () {
    document.querySelector('.player-controls .svg-icon-play, .player-controls .svg-icon-pause').parentElement.click();
  },
  next: function () {
    document.querySelector('.player-controls .svg-icon-next').parentElement.click();
  },
  favorite: function (){
    document.querySelector('.track-actions .svg-icon-love-outline').parentElement.click();
  },
  previous: function () {
    document.querySelector('.player-controls .svg-icon-prev').parentElement.click();
  },
  pause: function () {
    if (document.querySelector('.player-controls .svg-icon-pause')) {
      document.querySelector('.player-controls .svg-icon-pause').parentElement.click();
    }
  },
  trackInfo: function () {
    return {
      "track": document.querySelector('.track-title .track-link:nth-child(2)').innerText,
      "artist": document.querySelector('.track-title .track-link').innerText,
      "image": document.querySelector('.player-options .picture img').src.replace("28x28", "380x380"),
      "favorited": document.querySelector('.track-actions .svg-icon-love-outline').classList.contains('is-active')
    };
  }
}
