//
//  IndieShuffle.plist
//  BeardedSpice
//
//  Created by David Davis on 2015-06-30.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"IndieShuffle",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*indieshuffle.com*'",
    args: ["URL"]
  },
  isPlaying:function () { return document.querySelector('#currentSong .commontrack.active') != undefined;},
  toggle: function () {document.querySelector('#currentSong .commontrack').click()},
  next: function () {
    if(p=document.querySelector('#playNextSong')){
      p.click();
    }
  },
  previous: function () {
    if(p=document.querySelector('#prevSong .song_artwork')){
      p.click();
    }
  },
  pause: function () {
    if(p=document.querySelector('#currentSong .commontrack.active')){
      p.click();
    }
  },
  trackInfo: function () {
    var song = document.querySelector('#currentSong');
    return {
      'artist': song.querySelector('.artist_name').innerText,
      'track': song.querySelector('.song-details').innerText,
      'image':song.querySelector('img.song_artwork').getAttribute('src')
    }
  }
}
