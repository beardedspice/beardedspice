//
//  Rdio.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 1/9/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Rdio",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*rdio.com*'",
    args: ["URL"]
  },
  toggle: function () {window.R.player.playPause()},
  next: function () {window.R.player.next()},
  previous: function () {window.R.player.previous()},
  pause: function () {window.R.player.pause()},
  trackInfo: function () {}
}
