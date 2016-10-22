//
//  Xiami.js
//  BeardedSpice
//
//  Created by Weslly on 4/2/2016.
//  Converted to js by Alex Evers on 10/22/2016
//
//  Copyright (c) 2015 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Xiami",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*xiami.com/play*'",
    args: ["URL"]
  },

  isPlaying: function () {
    var t = document.querySelector('.pause-btn');
    return (t.style.display==='block');
  },
  toggle:    function () { document.querySelector('#J_playBtn').click(); },
  previous:  function () { document.querySelector('.prev-btn').click(); },
  next:      function () { document.querySelector('.next-btn').click(); },
  pause:     function () { /* pause site playing */ },
  favorite:  function () { document.querySelector('#J_trackFav').click(); },

  trackInfo: function () {
    return {
      'track':  document.querySelector('#J_trackName').innerText,
      'artist': document.querySelector('#J_trackName + a').innerText,
      'album': document.querySelector('#J_playerCoverImg').alt.replace('-' + document.querySelector('#J_trackName + a').innerText, ''),
      'image': document.querySelector('#J_playerCoverImg').src,
      'favorited': document.querySelector('#J_trackFav').classList.contains('icon-faved'),
    };
  }
}
