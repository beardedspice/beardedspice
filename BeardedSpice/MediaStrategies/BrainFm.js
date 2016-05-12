//
//  BrainFmStrategy.m
//  BeardedSpice
//
//  Created by James Greenleaf on 03/05/16.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version: 1,
  displayName: "Brain.fm",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format: "SELF LIKE[c] '*brain.fm/app*'",
    args: "url"
  },
  isPlaying: function () {
    var p = document.querySelector('#play_button');
    return p.classList.contains('tc_pause');
  },
  toggle: function () {document.querySelectorAll('#play_button')[0].click();},
  previous: function () {},
  next: function () {return document.querySelectorAll('#skip_button')[0].click()},
  pause: function () {
    var p = document.querySelectorAll('#play_button')[0];
    if(p.classList.contains('tc_pause')){
      p.click();
    }
  },
  favorite: function () {},
  trackInfo: function (){
    return {
      track: document.querySelector('#playing_title').textContent
    }
  }
}
