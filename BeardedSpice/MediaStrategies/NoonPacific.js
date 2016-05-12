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
  isPlaying: function() { return document.querySelector('.fa-pause') ? true:false;},
  toggle: function () {return document.querySelectorAll('.fa-fw')[1].click()},
  next: function () {return document.querySelector('.fa-forward').click()},
  previous: function () {return document.querySelector('.fa-backward').click()},
  pause: function () {return document.querySelector('.fa-pause').click()},
  trackInfo: function () {
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
