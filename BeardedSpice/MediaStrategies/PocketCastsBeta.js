//
//  PocketCastsBeta.plist
//  BeardedSpice
//
//  Created by Carlos Filoteo on 11/14/17.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"PocketCastsBeta",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*playbeta.pocketcasts.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    const audio = document.querySelector('audio')
    return !audio.paused && audio.currentTime > 0 && !audio.ended
  },
  toggle: function () {document.querySelector('.play_pause_button').click()},
  next: function () {document.querySelector('.skip_forward_button').click()},
  previous: function () {document.querySelector('.skip_back_button').click()},
  pause: function () {document.querySelector('.pause_button').click()},
  trackInfo: function () {
    return {
      'track': document.querySelector('.episode-title').innerText,
      'album': document.querySelector('.podcast-title').innerText,
      'image': document.querySelector('.podcast-image img').src,
    }
  }
}
