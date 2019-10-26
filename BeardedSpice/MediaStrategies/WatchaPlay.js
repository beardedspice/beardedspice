//
//  WatchaPlayStrategy.m
//  BeardedSpice
//
//  Created by KimJongMin on 2016. 3. 1..
//  Copyright © 2016년  GPL v3 http://www.gnu.org/licenses/gpl.html
//
// strategy/site notes
// - favorite, not implemented on this site
// - next/prev not solved here, TODO: send left/right arrow key events for 5 second skips
BSStrategy = {
  version:1,
  displayName:"Watcha Play",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*play.watcha.net/watch*'",
    args: ["URL"]
  },
  isPlaying:function () {
    var v = document.querySelector('video');
    return v && !v.paused;
  },
  toggle:function () {
    var v=document.querySelector('video');
    if (v) { v.paused ? v.play() : v.pause(); }
  },
  next: function () {},
  favorite: function () {},
  previous: function () {},
  pause:function () {
    var v=document.querySelector('video');
    v && v.pause();
  },
  trackInfo: function () {
    var track = document.querySelector('.vjs-display');
    return {
        track: track ? track.innerText : ''
    }
  }
}
