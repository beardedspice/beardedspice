//
//  AmazonAlexa.js
//  BeardedSpice
//
//  Created by Bret Martin on 2017-01-02
//  Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version: 1,
  displayName: "Amazon Alexa",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*alexa.amazon.com*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return document.querySelector('#d-play-pause').classList.contains('pause');
  },
  toggle:    function () { document.querySelector('#d-play-pause').click(); },
  previous:  function () { document.querySelector('#d-previous')  .click(); },
  next:      function () { document.querySelector('#d-next')      .click(); },
  pause:     function () { document.querySelector('#d-play-pause').click(); },
  trackInfo: function () {
    return {
        'track':  document.querySelector('div.d-main-text') .innerText,
        'album':  document.querySelector('div.d-sub-text-2').innerText,
        'artist': document.querySelector('div.d-sub-text-1').innerText,
        'image':  document
                    .querySelector('#d-album-art #d-image img, ' +
                                   'div.d-album-art-wrapper img')
                    .src
    };
  }
}
