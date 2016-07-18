//
//  Vimeo.plist
//  BeardedSpice
//
//  Created by Antoine Hanriat on 08/08/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Vimeo",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*vimeo.com*'",
    args: ["URL"]
  },
  isPlaying: function () {},
  toggle: function () {return window.vimeo.active_player.paused?window.vimeo.active_player.play():window.vimeo.active_player.pause()},
  next: function () {},
  favorite: function () {},
  previous: function () {},
  pause: function () {return window.vimeo.active_player.pause()},
  trackInfo: function () {}
}
