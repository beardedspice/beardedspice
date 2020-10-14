//
//  BrainFmStrategy.m
//  BeardedSpice
//
//  Created by James Greenleaf on 03/05/16.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
//  Updated by Andy Chong (@andychongyz) on 14/10/20.
//

BSStrategy = {
  version: 1,
  displayName: "Brain.fm",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*brain.fm/app*'",
    args: ["URL"],
  },
  isPlaying: function () {
    return document.querySelector("[class^='PlayControl__pause']") !== null;
  },
  toggle: function () {
    document.querySelector("[class^='PlayControl__']").click();
  },
  previous: function () {},
  next: function () {
    return document.querySelector("[class^='Skip__skip']").click();
  },
  pause: function () {
    var p = document.querySelector("[class^='PlayControl__']");
    if (document.querySelector("[class^='PlayControl__pause']") !== null) {
      p.click();
    }
  },
  favorite: function () {},
  trackInfo: function () {
    return {
      track: document.querySelectorAll("[class^='Controls__brainState']")[1]
        .textContent,
    };
  },
};
