//
//  MusicForProgramming.plist
//  BeardedSpice
//
//  Created by Max Borghino on 12/01/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
// strategy/site notes
// - favorite, not implemented on this site
// - single sets are long, so next/prev implements the site's forward/rewind on the set
// - track info consists only of the set number and name, no artist or artwork
BSStrategy = {
  version:1,
  displayName:"MusicForProgramming",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*musicforprogramming.net/*'",
    args: ["URL"]
  },
  isPlaying: function () {return ( (document.querySelector('.playerControls #player_playpause').innerText === '[PAUSE]'));},
  toggle: function () {document.querySelector('.playerControls #player_playpause').click();},
  next: function () {document.querySelector('.playerControls #player_ffw').click()},
  favorite: function () {},
  previous: function () {document.querySelector('.playerControls #player_rew').click()},
  pause:function () {
    var playPause=document.querySelector('.playerControls #player_playpause');
    if(playPause && playPause.innerText === '[PAUSE]'){
        playPause.click();
    }
  },
  trackInfo: function () {
    var track=document.querySelector('.selected');
    return {
        'track': track ? track.innerText : ''
    }
  }
}
