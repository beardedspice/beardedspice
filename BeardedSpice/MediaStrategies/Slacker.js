//
//  Slacker.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 1/18/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Slacker",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*slacker.com*'",
    args:"url"
  },
  isPlaying: function () {},
  toggle: function () {window.playPause()},
  next: function () {window.skip()},
  favorite: function () {},
  previous: function () {window.skipBack()},
  pause: function () {window.PLAYER_ENGINE.pause()},
  trackInfo: function () {}
}
