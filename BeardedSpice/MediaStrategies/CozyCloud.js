//
//  CozyCloud.js
//  BeardedSpice
//
//  Created by Cédric Patchane on 08/02/16.
//  Copyright (c) 2016 GPL v3 http://www.gnu.org/licenses/gpl.html
//

BSStrategy = {
  version: 1,
  displayName: "Cozy Cloud",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*cozycloud.cc/#apps/cozy-music/*'",
    args: ["URL"]
  },
  isPlaying: function () {
    iFrameDoc = document.querySelector('iframe').contentWindow.document;
    return iFrameDoc.querySelector('#play svg use').href === '#pause-lg';
  },
  toggle: function () {
    iFrameDoc = document.querySelector('iframe').contentWindow.document;
    iFrameDoc.querySelector('#play').click();
  },
  previous: function () {
    iFrameDoc = document.querySelector('iframe').contentWindow.document;
    iFrameDoc.querySelector('#prev').click();
  },
  next: function () {
    iFrameDoc = document.querySelector('iframe').contentWindow.document;
    iFrameDoc.querySelector('#next').click();
  },
  favorite: function () {},
  pause: function () {},
  trackInfo: function () {
    iFrameDoc = document.querySelector('iframe').contentWindow.document;
    return {
      //'image': '',
      'track': iFrameDoc.querySelector('#track-list li.playing .song-column-cell').innerText,
      'artist': iFrameDoc.querySelector('#track-list li.playing .artist-column-cell').innerText
    };
  }
}
