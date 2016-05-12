//
//  SoundCloud.plist
//  BeardedSpice
//
//  Created by Jose Falcon on 12/16/13.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"SoundCloud",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*soundcloud.com*'",
    args:"url"
  },
  isPlaying:function () {
    var play = document.querySelector('.playControl');
    return play.classList.contains('playing');
  },
  toggle: function () {return document.querySelectorAll('.playControl')[0].click()},
  next: function () {return document.querySelectorAll('.skipControl__next')[0].click()},
  favorite:function () {
    var play = document.querySelector('.playControl');
    if(play.classList.contains('playing')) { play.click(); }
  },
  previous: function () {return document.querySelectorAll('.skipControl__previous')[0].click()},
  pause: function (){return document.querySelector('div.playControls button.playbackSoundBadge__like').click()},
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
