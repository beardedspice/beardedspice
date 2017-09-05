//
//  Jamendo.plist
//  BeardedSpice
//
//  Created by Thomas Bekaert on 09/05/17.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Jamendo",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*jamendo.com*'",
    args: ["URL"]
  },
  isPlaying:function () {
    var play = document.querySelector('.player-mini_controls');
    return play.classList.contains('is-play');
  },
  toggle: function () {return document.querySelector('.player-controls_play').click()},
  next: function () {return document.querySelector('.player-controls_next').click()},
  favorite:function () {return document.querySelector('.player-mini_track-actions li:first-child button').click()},
  previous: function () {return document.querySelector('.player-controls_previous').click()},
  pause: function (){
      var play = document.querySelector('.player-mini_controls');
      if(play.classList.contains('is-play')) { play.click(); }
  },
  trackInfo: function () {
    var meta = document.querySelector('a.playbackSoundBadge__title.sc-truncate');
    return {
        'track': document.querySelector('.player-mini_track_information_title span').innerText,
        'album': document.querySelector('.player-mini_track_information_artist').innerText,
        'image': document.querySelector('#skeleton-player-full .player_cover img.js-full-player-cover-img').getAttribute('src'),
        'favorited': document.querySelector('.player-mini_track-actions li:first-child button').classList.contains('is-on')
    }
  }
}
