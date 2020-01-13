//
//  PinchyDon.js
//  BeardedSpice
//
//  Created by Vito Belgiorno-Zegna on 1/25/19.
//  Copyright (c) 2019 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "PinchyDon",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*pinchyandfriends.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return !document.querySelector("audio").paused;
  },
  toggle: function () {
    var a = document.querySelector("audio");
    a.paused ? a.play() : a.pause();
  },
  pause: function () {
    document.querySelector("audio").pause();
  },
  trackInfo: function () {
    return {
      "track": document.querySelector('.mixname_h1').textContent.split('by')[0].trim(),
      "artist": document.querySelector('.mixname_h1').textContent.split('by')[1].trim(),
      "image": document.querySelector("[class*='mix_img hand left'] > img").src
    }
  }
}
