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
  isPlaying: function () {},
  toggle: function () {window.app.mainViewModel.playerVM.togglePause()},
  next: function () {window.app.mainViewModel.playerVM.next()},
  favorite: function () {},
  previous: function () {window.app.mainViewModel.playerVM.previous()},
  pause: function () {
    var app = window.app.mainViewModel.playerVM;
    if(app.isPlayingOrLoading()) {
      app.togglePause()
    }
  },
  trackInfo: function () {}
}
