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
  isPlaying: function isPlaying () {},
  toggle: function toggle () {window.playPause()},
  next: function next () {window.skip()},
  favorite: function favorite () {},
  previous: function previous () {window.skipBack()},
  pause: function pause () {window.PLAYER_ENGINE.pause()},
  trackInfo: function trackInfo () {}
}
