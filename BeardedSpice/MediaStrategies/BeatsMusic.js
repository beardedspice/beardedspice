//
//  BeatsMusicStrategy.m
//  BeardedSpice
//
//  Created by John Bruer on 1/27/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Beats Music",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*listen.beatsmusic.com*'",
    args: ["URL"]
  },
  isPlaying: function () {},
  toggle: function () {document.querySelectorAll('#t-play')[0].click()},
  next: function () {document.querySelectorAll('#t-next')[0].click()},
  favorite: function () {},
  previous: function () {document.querySelectorAll('#t-prev')[0].click()},
  pause: function () {window.sm.pauseAll()},
  trackInfo: function () {}
}
