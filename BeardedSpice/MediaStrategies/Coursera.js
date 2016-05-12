//
//  Odnoklassniki.plist
//  BeardedSpice
//
//  Created by Andrei Glingeanu on 7/29/15.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Coursera",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*coursera.org*'",
    args: "url"
  },
  isPlaying: function () {
    var v = vjs(document.querySelectorAll('.video-js')[0].querySelector('video').id);
    return ! v.paused();
  },
  toggle: function () {
    var v = vjs(document.querySelectorAll('.video-js')[0].querySelector('video').id);
    if (v.paused()) {
      v.play();
    } else {
      v.pause();
    }
  },
  next: function () {return document.querySelectorAll('.c-item-side-nav-right .c-block-icon-link')[0].click()},
  previous: function () {return document.querySelectorAll('.c-item-side-nav-left .c-block-icon-link')[0].click()},
  pause: function () {
    var v = vjs(document.querySelectorAll('.video-js')[0].querySelector('video').id);
    v.pause();
  },
  trackInfo: function () {
    return {
      'track': document.querySelector('.c-video-title').firstChild.nodeValue,
      'artist': 'Coursera'
    }
  }
}
