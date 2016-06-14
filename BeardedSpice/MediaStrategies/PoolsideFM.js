//
//  PoolsideFM.js
//  BeardedSpice
//
//  Created by Coder-256 on 6/13/16.
//  Copyright (c) 2016 Coder-256. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName: "Poolside FM",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*poolside.fm*'",
    args: ["URL"]
  },
  isPlaying: function () {return document.querySelectorAll(".play:not(.pause)").length == 0 },
  toggle: function () {return document.querySelector(".play").click() },
  next: function () {return document.querySelector(".skip").click() },
  previous: function () {return true}, // No feature exists
  pause: function () { return document.querySelector(".pause").click() },
  play: function() { return document.querySelector(".play:not(.pause)").click() },
  trackInfo: function () {
    return {
        'track': document.querySelector(".title").innerText.trim().split("\n")[0],
        'artist': document.querySelector(".title").innerText.trim().split("\n")[1],
        'album': "", // No feature exists
        'image': ""  // No feature exists
    }
  }
}
