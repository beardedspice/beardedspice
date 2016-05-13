//
//  NRKStrategy.h
//  BeardedSpice
//
//  Created by Theodor Tonum on 8/24/15.
//  Copyright (c) 2015 Theodor Tonum. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"NRK",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*radio.nrk.no*'",
    args: ["URL"]
  },
  toggle: function () {return window.nrk.modules.player.getApi().toggleplay()},
  next: function () {},
  previous: function () {},
  pause: function () {return window.nrk.modules.player.getApi().pause()},
  favorite: function () {},
  trackInfo: function() {}
}
