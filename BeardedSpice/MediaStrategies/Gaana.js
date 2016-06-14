//
//  Gaana.js
//  BeardedSpice
//
//  Created by Coder-256 on 6/12/16.
//  Copyright (c) 2016 Coder-256. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName: "Gaana",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*gaana.com*'",
    args: ["URL"]
  },
  isPlaying: function () {return document.querySelectorAll(".pause").length > 0 },
  toggle: function () {return document.querySelector(".playPause").click() },
  next: function () {return document.querySelector(".next").click() },
  previous: function () {return document.querySelector(".prev").click() },
  pause: function () { return document.querySelector(".pause").click() },
  play: function() { return document.querySelector(".play").click() },
  trackInfo: function () {
    return {
        'track': document.querySelector("#tx").innerHTML.split(/<span>/)[0],
        'artist': document.querySelector("#tx > span:nth-child(2) > a").innerText,
        'album': document.querySelector("#tx > span:nth-child(1) > a").innerHTML.split(/<span>/)[0],
        'image': document.querySelector(".thumbHolder > img").src
    }
  }
}
