//
//  Eggheadio.js
//  BeardedSpice
//
//  Created by Carlos Filoteo on 3/20/17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"Egghead.io",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*egghead.io/lessons*'",
    args: ["URL"]
  },
  isPlaying:function () {
    return Wistia.api("wistia_").state() === "playing";
  },
  toggle: function () {
    var video = Wistia.api("wistia_");
    video.state() === "playing" ? video.pause() : video.play();
  },
  previous: function () {
    var e = document.querySelector(".up-next-list-item.current").parentElement.previousSibling;
    if(e){ e.childNodes[0].click(); }
  },
  next: function () {
    var e = document.querySelector(".up-next-list-item.current").parentElement.nextSibling;
    if(e){ e.childNodes[1].click(); }
  },
  pause:function () {
    Wistia.api("wistia_").pause();
  },
  trackInfo: function () {
    return {
      "track": document.querySelector("meta[itemprop=name]").getAttribute("content"),
      "artist": window.instructor,
      "image": document.querySelector("meta[itemprop=image]").getAttribute("content")
    }
  }
}
