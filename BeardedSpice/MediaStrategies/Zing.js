//
//  Zing.plist
//  BeardedSpice
//
//  Created by Alvin Nguyen on 06/23/16.
//  Updated by ToanPVN on 08/23/17.
//
BSStrategy = {
  version: 2,
  displayName: "Zing MP3",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*mp3.zing.vn/*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('#zp-svg-play') == null; },
  toggle: function(){ document.querySelector('.paused').click(); },
  previous: function(){ document.querySelector('.fn-prev').click(); },
  next: function(){ document.querySelector('.fn-list li:first-child a.thumb').click(); },
  pause: function(){ 
    if (document.querySelector('#zp-svg-play') == null) {
      document.querySelector('.paused').click();
    }
  },
  trackInfo: function () {
    return {
        'image': document.querySelector('.pthumb').getAttribute('src'),
        'track':  document.querySelector('.fn-song.fn-current .fn-name').innerText,
        'artist': document.querySelector('.fn-song.fn-current h4 a').innerText
    };
  }
}
