//
//  Udemy.plist
//  BeardedSpice
//
//  Created by Coder-256 on 10/3/15.
//  Updated by nelsonjchen on 11/24/16.
//  Updated by rkrv on 07/18/18.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version: 3,
  displayName: "Udemy",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*udemy.com*/lecture/*'",
    args: ["URL"]
  },

  isPlaying: function () { return !(document.querySelector('video-viewer video').paused); },

  toggle: function () {
    var theVideo = document.querySelector('video-viewer video');
    if (theVideo.paused) { theVideo.play(); }
    else { theVideo.pause() }
  },

  next: function () { document.querySelector("a.udi.udi-vjs-forward.btn").click(); },
  favorite: function () {},
  previous: function () { document.querySelector("a.udi.udi-vjs-rewind.btn").click(); },
  pause: function () { document.querySelector('video-viewer video').pause(); },

  trackInfo: function () {
    return {
      'track': document.querySelector('.course-info__title').textContent,
      'album': 'Udemy'
    }
  }
}
