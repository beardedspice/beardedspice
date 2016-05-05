//
//  Synology.plist
//  BeardedSpice
//
//  Created by Stephan van Diepen on 16/01/2014.
//  Copyright (c) 2013 Stephan van Diepen. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Synology Audio Station",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*synology.me*'",
    args:"url"
  },
  isPlaying: function isPlaying () {},
  toggle: function toggle () {document.querySelectorAll('.player-play button')[0].click()},
  next: function next () {document.querySelectorAll('.player-next button')[0].click()},
  favorite: function favorite () {},
  previous: function previous () {document.querySelectorAll('.player-prev button')[0].click()},
  pause: function pause () {document.querySelectorAll('.player-stop button')[0].click()},
  trackInfo: function trackInfo () {}
}
