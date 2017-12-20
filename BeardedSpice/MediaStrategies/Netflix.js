//
//  Netflix.plist
//  BeardedSpice
//
//  Updated by Hollister Starrett on 12/19/17.
//  Created by Max Borghino on 12/06/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
// strategy/site notes
// - favorite, not implemented on this site
// - next/prev not solved here, TODO: send left/right arrow key events for 10 second skips
// - track info consists only of the show name, no artist or artwork
BSStrategy = {
  version:1,
  displayName:"Netflix",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*netflix.com/watch/*'",
    args: ["URL"]
  },
  isPlaying:function () {
    var v=document.querySelector('video');
    return v ? !v.paused : false;
  },
  toggle:function () {
    var v=document.querySelector('video');
    if (v) {v.paused ? v.play() : v.pause();}
  },
  next: function () {},
  favorite: function () {},
  previous: function () {},
  pause:function () {
    var v=document.querySelector('video');
    v && v.pause();
  },
  trackInfo: function () {
    var track=document.querySelector('.player-status-main-title');
    return {
      'track': track ? track.innerText : ''
    }
  }
}
