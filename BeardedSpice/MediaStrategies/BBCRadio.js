//
//  BBCRadio.plist
//  BeardedSpice
//
//  Created by Max Borghino on 12/13/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
// strategy/site notes
// - no previous and next available on site
BSStrategy = {
  version:1,
  displayName:"BBC Radio",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*bbc.co.uk/radio/player/*'",
    args: "url"
  },
  isPlaying:function () {
    var s=document.querySelector('#controls');
    return (s && (s.classList.contains('stoppable') || s.classList.contains('pausable')));
  },
  toggle:function () {
    var s = document.querySelector('#controls');
    var play = document.querySelector('#btn-play');
    var pause = document.querySelector('#btn-pause');
    if (s && (s.classList.contains('stoppable') || s.classList.contains('pausable'))) {
      pause.click();
    } else {
      play.click();
    }
  },
  next: function next () {},
  favorite: function favorite () {document.querySelector('#toggle-mystations').click();},
  previous: function previous () {},
  pause: function pause () {document.querySelector('#btn-pause').click();},
  trackInfo: function trackInfo () {
    var playlister=document.querySelector('.playlister'), art, title, artist;
    if (playlister) {
      art=document.querySelector('.playlister img'),
      title=playlister.querySelector('.track .title'),
      artist=playlister.querySelector('.track .artist');
    } else {
      art=document.querySelector('#main-image-wrapper img'),
      title=document.querySelector('#parent-title a'),
      artist=document.querySelector('#title a');
    }
    return {'image': art ? art.getAttribute('src') : null,
            'track': title ? title.innerText : document.title,
            'artist': artist ? artist.innerText : null
    };
  }
}
