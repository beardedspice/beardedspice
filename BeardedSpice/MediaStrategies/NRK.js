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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*radio.nrk.no*'",
    args:"url"
  },
  toggle: function toggle () {return window.nrk.modules.player.getApi().toggleplay()},
  next: function next () {},
  previous: function previous () {},
  pause: function pause () {return window.nrk.modules.player.getApi().pause()},
  favorite: function favorite () {},
  trackInfo: function trackInfo() {}
}
