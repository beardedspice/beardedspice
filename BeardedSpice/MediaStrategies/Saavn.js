//
//  Saavn.plist
//  BeardedSpice
//
//  Created by Yash Aggarwal on 1/6/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Saavn",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*saavn.com*'",
    args:"url"
  },
  isPlaying: function isPlaying () {},
  toggle: function toggle () {
    var e = document.getElementById('play');
    var t = document.getElementById('pause');
    if (t.className.indexOf('hide')===-1) { t.click(); }
    else { e.click(); }
  },
  next: function next () { document.getElementById('fwd').click();},
  previous: function previous () { document.getElementById('rew').click();},
  pause: function pause () { document.getElementById('pause').click();},
  trackInfo: function trackInfo () {}
}
