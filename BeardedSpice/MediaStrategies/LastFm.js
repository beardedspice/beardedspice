//
//  LastFm.plist
//  BeardedSpice
//
//  Created by Tyler Rhodes on 12/19/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"LastFM",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*last.fm/listen*'",
    args: ["URL"]
  },
  toggle:function () {
    var e = document.querySelectorAll('#radioControlPlay')[0];
    var t = document.querySelectorAll('#radioControlPause')[0];
    var m = document.querySelectorAll('#webRadio')[0];
    if(m.classList.contains('paused')) { e.click() }
    else { t.click() }
  },
  next: function () {return document.querySelectorAll('#radioControlSkip')[0].click()},
  pause: function () {var t=document.querySelectorAll('#radioControlPause')[0].click()}
}
