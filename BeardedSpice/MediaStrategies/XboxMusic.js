//
//  XboxMusic.plist
//  BeardedSpice
//
//  Created by Jonathan Ruiz on 5/20/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Xbox Music",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*music.xbox.com*'",
    args:"url"
  },
  isPlaying: function isPlaying () {},
  toggle: function toggle () {window.app.mainViewModel.playerVM.togglePause()},
  next: function next () {window.app.mainViewModel.playerVM.next()},
  favorite: function favorite () {},
  previous: function previous () {window.app.mainViewModel.playerVM.previous()},
  pause: function pause () {
    var app = window.app.mainViewModel.playerVM;
    if(app.isPlayingOrLoading()) {
      app.togglePause()
    }
  },
  trackInfo: function trackInfo () {}
}
