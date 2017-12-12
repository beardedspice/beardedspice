//
//  AmazonPrimeVideo.js
//  BeardedSpice
//
//  Created by You on Today's Date.
//  Copyright (c) 2015-2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

// We put the copyright inside the plist to retain consistent syntax coloring.

// Use a syntax checker to ensure validity. One is provided by nodejs (`node -c filename.js`)
// Normal formatting is supported (can copy/paste with newlines and indentations)

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
