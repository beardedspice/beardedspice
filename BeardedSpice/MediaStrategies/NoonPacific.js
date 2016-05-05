//
//  NoonPacific.m
//  BeardedSpice
//
//  Created by Tomas on 07/05/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Noon Pacific",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*noonpacific.com*'",
    args:"url"
  },
  isPlaying: function isPlaying() { return document.querySelector('.fa-pause') ? true:false;},
  toggle: function toggle () {return document.querySelectorAll('.fa-fw')[1].click()},
  next: function next () {return document.querySelector('.fa-forward').click()},
  previous: function previous () {return document.querySelector('.fa-backward').click()},
  pause: function pause () {return document.querySelector('.fa-pause').click()},
  trackInfo: function trackInfo () {
    var track = document.querySelectorAll('.track-info div p');
    var imgSrc = document.querySelector('.mixtape-container img.mixtape').getAttribute('src');
    var album = document.querySelector('.mixtape-container div.mixtape-label h3').innerText;
    return {
      'track':track[0].firstChild.nodeValue,
      'artist':track[1].firstChild.nodeValue,
      'album':album,
      'image':imgSrc
    }
  }
}
