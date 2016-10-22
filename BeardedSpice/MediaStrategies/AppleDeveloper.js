//
//  AppleDeveloper.js
//  BeardedSpice
//
//  Created by Chloe Stars on 8/16/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Apple Developer",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*developer.apple.com/videos/play/*'",
    args: ["URL"]
  },
  isPlaying: function () {return !(document.querySelector('video').paused);},
  toggle: function () {
    var theVideo = document.getElementsByTagName("video")[0];
    if (theVideo.paused) { theVideo.play(); }
    else { theVideo.pause() }
  },
  next: function () {},
  favorite: function () {},
  previous: function () {},
  pause: function () {document.getElementsByTagName("video")[0].pause();},
  trackInfo: function () {
    return {
      'track': document.getElementsByClassName("supplement details active")[0].getElementsByTagName("h1")[0].textContent,
      'album': 'Apple'
    }
  }
}
