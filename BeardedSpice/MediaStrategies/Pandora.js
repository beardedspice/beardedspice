//
//  Pandora.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Pandora",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*pandora.com*'",
    args:"url"
  },
  isPlaying: function isPlaying () {
    var t = document.querySelector('.pauseButton');
    return (t.style.display === 'block');
  },
  toggle: function toggle () {
    var e = document.querySelector('.playButton');
    var t = document.querySelector('.pauseButton');
    if(t.style.display==='block') { t.click() }
    else { e.click() }
  },
  next: function next () { document.querySelector('.skipButton').click(); },
  pause: function pause () { document.querySelector('.pauseButton').click(); },
  trackInfo: function trackInfo () {
    return {
      'track': document.querySelector('.playerBarSong').innerText,
      'artist': document.querySelector('.playerBarArtist').innerText,
      'album': document.querySelector('.playerBarAlbum').innerText,
      'image': document.querySelector('.playerBarArt').src
    };
  }
}
