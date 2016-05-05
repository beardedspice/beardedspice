//
//  Blitzr.plist
//  BeardedSpice
//
//  Created by Pascal Fouque on 23/07/2015.
//  Copyright (c) 2015 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Blitzr",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*blitzr.com*'",
    args: "url"
  },
  isPlaying: function isPlaying () { return document.querySelector('#blitzr_playpause span.fa').className.indexOf('fa-play') == -1 },
  toggle: function toggle () {document.querySelector('#blitzr_playpause').click()},
  next: function next () {document.querySelector('#blitzr_next').click()},
  previous: function previous () {document.querySelector('#blitzr_prev').click()},
  pause: function pause () {
    if (document.querySelector('#blitzr_playpause span.fa').className.indexOf('fa-play') == -1) {
      document.querySelector('#blitzr_playpause').click()
    }
  },
  trackInfo: function trackInfo () {
    return {
      'track': document.querySelector('#playerTitle strong').innerHTML,
      'album': document.querySelector('#playerInfo .media-left a').title,
      'artist': document.querySelectorAll('#playerArtists')[0].querySelector('a').innerHTML,
      'image': document.querySelector('#playerInfo .media-left a img').style['background-image'].slice(4, -1),
    }
  }
}
