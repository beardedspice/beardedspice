//
//  Overcast.plist
//  BeardedSpice
//
//  Created by Alan Clark 08/06/2014
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
// strategy/site notes
// - favorite: not implemented by site
BSStrategy = {
  version:1,
  displayName:"Overcast.fm",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*overcast.fm*'",
    args:"url"
  },
  isPlaying:function () {
    var p=document.querySelector('#playpausebutton_playicon');
    return (p && p.style.display==='none');
  },
  toggle: function toggle () { document.getElementById('playpausebutton').click();},
  next: function next () { document.getElementById('seekforwardbutton').click();},
  previous: function previous () { document.getElementById('seekbackbutton').click();},
  pause: function pause () {
    var p=document.querySelector('#playpausebutton_playicon');
    if(p && p.style.display==='none'){
      document.getElementById('playpausebutton').click();
    }
  },
  trackInfo: function trackInfo () {
    var artist=document.querySelector('.caption2 a');
    var track=document.querySelector('.title');
    var art=document.querySelector('.art.fullart');
    return {
      'artist': artist ? artist.innerText : null,
      'track': track ? track.innerText : null,
      'image': art ? art.getAttribute('src') : null
    };
  }
}
