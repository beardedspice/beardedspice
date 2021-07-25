//  BeardedSpice
//
//  Created by Mike Lloyd on 8/27/2017.
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "WETA",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*weta.org/listen-live*'",
    args: ["URL"]
  },

  isPlaying:function () {
    var e = document.querySelector('.jp-pause');
    return e.style.display === 'block';
  },
  toggle: function () {
    var e = document.querySelector('.jp-pause');
    if(e.style.display === 'block') {
      document.querySelector('.jp-pause').click();
    } else {
      document.querySelector('.jp-play').click();
    }
  },
  next: function () {},
  previous: function () {},
  favorite: function () {},
  pause: function () {document.querySelector('.jp-pause').click()},
  trackInfo: function () {
    return {
      'track':  document.querySelector('.jp-type-single p').innerText.replace(/\"/g,''),
      'artist': document.querySelector('.jp-type-single h5').innerText.replace(/\"/g,'')
    }
  }
}
