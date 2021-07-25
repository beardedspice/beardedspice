//
//  AmazonPrimeVideo.js
//  BeardedSpice
//
//  Created by Marc-Antoine Brodeur on 2017-12-13.
//  Copyright (c) 2016-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Amazon Prime Video",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*primevideo.com*'",
    args: ["URL"]
  },

  isPlaying: function () { 
    var video = document.querySelector('video');

    return !!(video.currentTime > 0 && !video.paused && !video.ended && video.readyState > 2);
  },
  toggle:    function () { 
    var video = document.querySelector('video');

    if(!!(video.currentTime > 0 && !video.paused && !video.ended && video.readyState > 2)){
      video.pause();
    } else {
      video.play();
    }
  },
  previous:  function () {},
  next:      function () {},
  pause:     function () { 
    var video = document.querySelector('video');
    video.pause();
  },
  favorite:  function () {},
  trackInfo: function () {
    return {
      'track': document.querySelector('.contentTitlePanel .subtitle').innerText,
      'album': document.querySelector('.contentTitlePanel .title').innerText
    };
  }
}
