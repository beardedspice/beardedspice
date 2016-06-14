//
//  Beatguide.plist
//  BeardedSpice
//
//  Created by Colin White on 08/04/15.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Beatguide",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*beatguide.me*'",
    args: ["URL"]
  },
  isPlaying: function () {return ($('.pause-icon').css('display') == 'block');},
  toggle: function () {return document.querySelectorAll('.play-icon')[0].click()},
  next: function () {return document.querySelectorAll('.fa-forward')[0].click()},
  previous: function () {return document.querySelectorAll('.fa-backward')[0].click()},
  pause: function () {return document.querySelectorAll('.fa-pause')[0].click()},
  trackInfo: function () {
    return {
      'track': document.querySelectorAll('.track-title')[0].innerText,
      'artist': document.querySelectorAll('.artist-name')[0].innerText,
      'image': document.querySelectorAll('.track-artwork')[0].src
    }
  }
}
