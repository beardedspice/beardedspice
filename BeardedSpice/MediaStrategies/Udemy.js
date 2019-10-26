//
//  Udemy.plist
//  BeardedSpice
//
//  Created by Coder-256 on 10/3/15.
//  Updated by nelsonjchen on 11/24/16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:2,
  displayName:"Udemy",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*udemy.com*/lecture/*'",
    args: ["URL"]
  },
  isPlaying: function () {return !(document.querySelector('video-player video').paused);},
  toggle: function () {
    var theVideo = document.querySelector('video-player video');
    if (theVideo.paused) { theVideo.play(); }
    else { theVideo.pause() }
  },
  next: function () {document.querySelector("a.udi.udi-vjs-forward.btn").click()},
  favorite: function () {},
  previous: function () {document.querySelector("a.udi.udi-vjs-rewind.btn").click()},
  pause: function () {document.querySelector('video-player video').pause();},
  trackInfo: function () {
    return {
      'track': document.querySelector('.course-info__title').textContent,
      'album': 'Udemy'
    }
  }
}
