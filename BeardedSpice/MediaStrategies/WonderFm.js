//
//  WonderFm.plist
//  BeardedSpice
//
//  Created by Kyle Conarro on 2/3/15.
//  Copyright (c) 2015 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"WonderFM",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*wonder.fm*'",
    args:"url"
  },
  isPlaying: function isPlaying () {return $('div.jp-audio').hasClass('jp-state-playing');},
  toggle: function toggle () {
    var e = document.querySelector('.jp-type-single');
    var u = 'none' === getComputedStyle(e,null).display;
    var n = 'none' === getComputedStyle(l,null).display;
    if (u) {
      var c = document.querySelector('.track_play');
      c.click();
    }
    else if (n) {
      var t = document.querySelector('a.jp-pause');
      t.click();
    }
    else {
      var l = document.querySelector('a.jp-play');
      l.click();
    }
  },
  next: function next () {document.querySelector('a.jp-next').click()},
  favorite:function favorite () { document.querySelector('.track_active .track_fav').click() },
  previous: function previous () {},
  pause: function pause () {document.querySelector('a.jp-pause').click()},
  trackInfo: function trackInfo () {
    return {
      'track': document.querySelector('.track_active .track_name > a').text,
      'artist': document.querySelector('.track_active .track_artist > a').text
    }
  }
}
