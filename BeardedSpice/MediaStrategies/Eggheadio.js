//
//  Eggheadio.js
//  BeardedSpice
//
//  Created by Carlos Filoteo on 3/20/17.
//  v2 updated 8/9/17
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 2,
  displayName: "Egghead.io",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*egghead.io/lessons*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return document.querySelector("video").paused;
  },
  toggle: function () {
    var v = document.querySelector("video");
    v.paused ? v.play() : v.pause();
  },
  previous: function () {
    var e = document.querySelector(".nowPlaying").previousSibling;
    if(e){ e.childNodes[0].click(); }
  },
  next: function () {
    var e = document.querySelector(".nowPlaying").nextSibling;
    if(e){ e.childNodes[0].click(); }
  },
  pause: function () {
    document.querySelector("video").pause();
  },
  trackInfo: function () {
    return {
      "track": document.querySelector("meta[itemprop=name]").getAttribute("content"),
      "artist": window.egh_page.data.instructor,
      "image": document.querySelector("[class*='index__icon__'] > img").src
    }
  }
}
