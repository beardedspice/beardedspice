//
//  iHeartRadioStrategy.m
//  BeardedSpice
//
//  Created by Coder-256 on 2/7/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"iHeartRadio",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*iheart.com*'",
    args:"url"
  },
  isPlaying: function isPlaying() { document.querySelectorAll('[aria-label="Stop"], [aria-label="Pause"]').length > 0 },
  toggle:function toggle () {
    if (document.querySelectorAll('[aria-label="Stop"], [aria-label="Pause"]').length > 0) {
      try{
        document.querySelector('[aria-label="Stop"]').click();
      } catch(e){
        document.querySelector('[aria-label="Pause"]').click();
      }
    } else {
      var plays = document.querySelectorAll('[aria-label="Play Station"]');
      plays[plays.length-1].click();
    }
  },
  next: function next () {document.querySelector('[aria-label="Skip"]').click();},
  favorite: function favorite () {},
  previous: function previous () {},
  pause: function pause () {document.querySelector('[aria-label="Stop"]').click();},
  trackInfo: function trackInfo () {
    return {
      'track': document.querySelector(".player-song").textContent,
      'album': document.querySelector(".player-artist").textContent,
      'image': document.querySelector(".player-art > img").src.split("?")[0]
    };
  }
}
