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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*beatguide.me*'",
    args: "url"
  },
  isPlaying: function isPlaying () {return ($('.pause-icon').css('display') == 'block');},
  toggle: function toggle () {return document.querySelectorAll('.play-icon')[0].click()},
  next: function next () {return document.querySelectorAll('.fa-forward')[0].click()},
  previous: function previous () {return document.querySelectorAll('.fa-backward')[0].click()},
  pause: function pause () {return document.querySelectorAll('.fa-pause')[0].click()},
  trackInfo: function trackInfo () {
    return {
      'track': document.querySelectorAll('.track-title')[0].innerText,
      'artist': document.querySelectorAll('.artist-name')[0].innerText,
      'image': document.querySelectorAll('.track-artwork')[0].src
    }
  }
}
