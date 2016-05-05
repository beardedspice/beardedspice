//
//  SomaFm.plist
//  BeardedSpice
//
//  Created by Max Borghino on 1/28/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"SomaFM",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*somafm.com/player/*'",
    args:"url"
  },
  isPlaying: function isPlaying () {return ( (document.querySelector('#stopBtn:not(.ng-hide)') ? true : false));},
  toggle: function toggle () {(document.querySelector('#playBtn:not(.ng-hide)') || document.querySelector('#stopBtn:not(.ng-hide)')).click()},
  next: function next () {},
  favorite: function favorite () {document.querySelector('.row.card').querySelector('button').click()},
  previous: function previous () {},
  pause: function pause () {
    if(p=document.querySelector('#stopBtn:not(.ng-hide)')){
      p.click();
    }
  },
  trackInfo: function trackInfo () {
    var art = document.querySelector('.img-responsive').getAttribute('src');
    var card = document.querySelector('.row.card').querySelectorAll('div');
    return {
      'track': card[1].firstChild.innerText,
      'artist': card[2].firstChild.innerText,
      'favorited': card[3].firstChild.className.indexOf('btn-fav') > -1,
      'image': art
    }
  }
}
