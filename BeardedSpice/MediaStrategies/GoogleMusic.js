//
//  GoogleMusic.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 1/9/14.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"GoogleMusic",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*play.google.com/music/*'",
    args:"url"
  },
  isPlaying:function isPlaying () {
    var e = document.querySelector('[data-id=play-pause]');
    return e.classList.contains('playing');
  },
  toggle: function toggle () {document.querySelector('[data-id=play-pause]').click()},
  next: function next () {document.querySelector('[data-id=forward]').click()},
  favorite: function () { document.querySelector('paper-icon-button[data-rating="5"]').click() },
  previous: function previous () {document.querySelector('[data-id=rewind]').click()},
  pause: function pause () {
    var e = document.querySelector('[data-id=play-pause]');
    if(e.classList.contains('playing')){
        e.click()
    }
  },
  trackInfo: function trackInfo () {
    return {
      'track':  document.getElementById('currently-playing-title').innerText,
      'album':  document.getElementsByClassName('player-album')[0].innerText,
      'artist': document.getElementById('player-artist').innerText,
      'image':  document.getElementById('playingBarArt').getAttribute('src')
    }
  }
}
