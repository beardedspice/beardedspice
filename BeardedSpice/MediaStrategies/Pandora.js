//
//  Pandora.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//  Modified by Anthony Whitaker on 12/13/16
//
BSStrategy = {
  version:2,
  displayName:"Pandora",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*pandora.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    var t = document.querySelector('.pauseButton');
    return (t.style.display === 'block');
  },
  toggle: function () {
    var e = document.querySelector('.playButton');
    var t = document.querySelector('.pauseButton');
    if(t.style.display==='block') { t.click() }
    else { e.click() }
  },
  next: function () { document.querySelector('.skipButton').click(); },
  pause: function () { document.querySelector('.pauseButton').click(); },
  favorite: function() { document.querySelector('.thumbUpButton').click(); },
  trackInfo: function () {
    return {
      'track': document.querySelector('.playerBarSong').innerText,
      'artist': document.querySelector('.playerBarArtist').innerText,
      'album': document.querySelector('.playerBarAlbum').innerText,
      'image': document.querySelector('.playerBarArt').src,
      'favorited': document.querySelector('.thumb').style.display === 'block' && document.querySelector('.thumb').id === 'thumbup'
    };
  }
}
