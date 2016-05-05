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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*deezer.com*'",
    args: "url"
  },
  toggle: function toggle () {dzPlayer.control.togglePause()},
  next: function next () {dzPlayer.control.nextSong()},
  favorite: function favorite (){return document.querySelectorAll('a.icon-love-circle')[0].click()},
  previous: function previous () {dzPlayer.control.prevSong()},
  pause: function pause () {dzPlayer.control.pause()}
}
