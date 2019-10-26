//
//  iHeartRadioStrategy.m
//  BeardedSpice
//
//  Created by Coder-256 on 2/7/16.
//  Copyright © 2016  GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"iHeartRadio",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*iheart.com*'",
    args: ["URL"]
  },
  isPlaying: function() { document.querySelectorAll('[aria-label="Stop"], [aria-label="Pause"]').length > 0 },
  toggle:function () {
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
  next: function () {document.querySelector('[aria-label="Skip"]').click();},
  favorite: function () {},
  previous: function () {},
  pause: function () {document.querySelector('[aria-label="Stop"]').click();},
  trackInfo: function () {
    return {
      'track': document.querySelector(".player-song").textContent,
      'album': document.querySelector(".player-artist").textContent,
      'image': document.querySelector(".player-art > img").src.split("?")[0]
    };
  }
}
