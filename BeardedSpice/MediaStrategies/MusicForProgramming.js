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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*musicforprogramming.net/*'",
    args:"url"
  },
  isPlaying: function isPlaying () {return ( (document.querySelector('.playerControls #player_playpause').innerText === '[PAUSE]'));},
  toggle: function toggle () {document.querySelector('.playerControls #player_playpause').click();},
  next: function next () {document.querySelector('.playerControls #player_ffw').click()},
  favorite: function favorite () {},
  previous: function previous () {document.querySelector('.playerControls #player_rew').click()},
  pause:function () {
    var playPause=document.querySelector('.playerControls #player_playpause');
    if(playPause && playPause.innerText === '[PAUSE]'){
        playPause.click();
    }
  },
  trackInfo: function trackInfo () {
    var track=document.querySelector('.selected');
    return {
        'track': track ? track.innerText : ''
    }
  }
}
