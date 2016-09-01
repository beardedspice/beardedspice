//
//  SoundCloud.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"SoundCloud",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*soundcloud.com*'",
    args: ["URL"]
  },
  isPlaying:function () {
    var play = document.querySelector('.playControl');
    return play.classList.contains('playing');
  },
  toggle: function () {return document.querySelectorAll('.playControl')[0].click()},
  next: function () {return document.querySelectorAll('.skipControl__next')[0].click()},
  favorite:function () {return document.querySelector('div.playControls button.playbackSoundBadge__like').click()},
  previous: function () {return document.querySelectorAll('.skipControl__previous')[0].click()},
  pause: function (){
      var play = document.querySelector('.playControl');
      if(play.classList.contains('playing')) { play.click(); }
  },
  trackInfo: function () {
    var meta = document.querySelector('a.playbackSoundBadge__title.sc-truncate');
    return {
        'track': meta.title,
        'album': meta.href.split('/')[3],
        'image': document.querySelector('div.playControls span.sc-artwork').style['background-image'].slice(4, -1),
        'favorited': document.querySelector('div.playControls button.playbackSoundBadge__like').classList.contains('sc-button-selected')
    }
  }
}
