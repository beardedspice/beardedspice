//
//  LeTournedisque.plist
//  BeardedSpice
//
//  Created by Jonas Friedmann on 18.05.15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"LeTournedisque",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*letournedisque.com*'",
    args:"url"
  },
  isPlaying: function () {return (document.querySelectorAll('.playing')[0]) ? true : false},
  toggle: function () {return document.querySelectorAll('div.play')[0].click()},
  next: function () {return document.querySelectorAll('div.next')[0].click()},
  previous: function () {return document.querySelectorAll('div.prev')[0].click()},
  pause: function () {return document.querySelectorAll('div.playing')[0].click()},
  trackInfo: function () {
    return {
      'artist': $('.info-text .artiste strong, .info-text .artiste a').text(),
      'track': $.trim($('.info-text .name').text())
    };
  }
}
