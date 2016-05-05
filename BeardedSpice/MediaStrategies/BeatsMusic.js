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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*listen.beatsmusic.com*'",
    args: "url"
  },
  isPlaying: function isPlaying () {},
  toggle: function toggle () {document.querySelectorAll('#t-play')[0].click()},
  next: function next () {document.querySelectorAll('#t-next')[0].click()},
  favorite: function favorite () {},
  previous: function previous () {document.querySelectorAll('#t-prev')[0].click()},
  pause: function pause () {window.sm.pauseAll()},
  trackInfo: function trackInfo () {}
}
