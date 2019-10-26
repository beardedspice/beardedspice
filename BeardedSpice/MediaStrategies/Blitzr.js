//
//  Blitzr.plist
//  BeardedSpice
//
//  Created by Pascal Fouque on 23/07/2015.
//  Copyright (c) 2015  GPL v3 http://www.gnu.org/licenses/gpl.html
//
BSStrategy = {
  version:1,
  displayName:"Blitzr",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*blitzr.com*'",
    args: ["URL"]
  },
  isPlaying: function () { return document.querySelector('#blitzr_playpause span.fa').className.indexOf('fa-play') == -1 },
  toggle: function () {document.querySelector('#blitzr_playpause').click()},
  next: function () {document.querySelector('#blitzr_next').click()},
  previous: function () {document.querySelector('#blitzr_prev').click()},
  pause: function () {
    if (document.querySelector('#blitzr_playpause span.fa').className.indexOf('fa-play') == -1) {
      document.querySelector('#blitzr_playpause').click()
    }
  },
  trackInfo: function () {
    return {
      'track': document.querySelector('#playerTitle strong').innerText,
      'album': document.querySelector('#playerInfo .media-left a').title,
      'artist': document.querySelectorAll('#playerArtists')[0].querySelector('a').innerText,
      'image': document.querySelector('#playerInfo .media-left a img').style['background-image'].slice(4, -1),
    }
  }
}
