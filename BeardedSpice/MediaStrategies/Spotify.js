//
//  Spotify.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/19/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Spotify",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*play*.spotify.com*'",
    args: ["URL"]
  },
  isPlaying:function() { document.querySelector('#app-player').contentWindow.document.querySelector('#play-pause').classList.contains('playing') },
  toggle: function () {document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#play-pause')[0].click()},
  next: function () {document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#next')[0].click()},
  favorite: function () {},
  previous: function () {document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#previous')[0].click()},
  pause:function () {
    var e = document.querySelectorAll('#app-player')[0].contentWindow.document.querySelectorAll('#play-pause')[0];
    if(e.classList.contains('playing')) { e.click() }
  },
  trackInfo: function () {}
}
