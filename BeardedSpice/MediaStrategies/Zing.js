//
//  Zing.plist
//  BeardedSpice
//
//  Created by Alvin Nguyen on 06/23/16.
//
BSStrategy = {
  version: 1,
  displayName: "Zing MP3",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*mp3.zing.vn/*'",
    args: ["URL"]
  },
  toggle: function(){ document.querySelector('.jp-play').click(); },
  previous: function(){ document.querySelector('.fn-prev').click(); },
  next: function(){ document.querySelector('.fn-next').click(); },
  pause: function(){ document.querySelector('.jp-pause').click(); },
  trackInfo: function () {
    return {
        'image': document.querySelector('.pthumb').getAttribute('src'),
        'track':  document.querySelector('.fn-song.fn-current .fn-name').innerText,
        'artist': document.querySelector('.fn-song.fn-current h4 a').innerText
    };
  }
}
