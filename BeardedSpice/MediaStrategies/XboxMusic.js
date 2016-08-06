//
//  XboxMusic.plist
//  BeardedSpice
//
//  Created by Jonathan Ruiz on 5/20/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"Xbox Music",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.microsoft.com*'",
    args: ["URL"]
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
