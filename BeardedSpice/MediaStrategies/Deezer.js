//
//  Deezer.plist
//  BeardedSpice
//
//  Created by Greg Woodcock on 06/01/2015.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Deezer",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*deezer.com*'",
    args: ["URL"]
  },
  toggle: function () {dzPlayer.control.togglePause()},
  next: function () {dzPlayer.control.nextSong()},
  favorite: function (){return document.querySelectorAll('a.icon-love-circle')[0].click()},
  previous: function () {dzPlayer.control.prevSong()},
  pause: function () {dzPlayer.control.pause()}
}
