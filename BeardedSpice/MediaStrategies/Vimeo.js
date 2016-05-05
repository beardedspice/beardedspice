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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*vimeo.com*'",
    args:"url"
  },
  isPlaying: function isPlaying () {},
  toggle: function toggle () {return window.vimeo.active_player.paused?window.vimeo.active_player.play():window.vimeo.active_player.pause()},
  next: function next () {},
  favorite: function favorite () {},
  previous: function previous () {},
  pause: function pause () {return window.vimeo.active_player.pause()},
  trackInfo: function trackInfo () {}
}
