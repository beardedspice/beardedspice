//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by Jinseop Kim on 01/03/16.
//  Copyright © 2016-2017 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version: 2,
  displayName: "Bugs Music",
  accepts: {
    method: "predicateOnTab",
    format: "%K LIKE[c] '*music.bugs.co.kr/newPlayer*'",
    args: ["URL"]
  },
  isPlaying: function () {
    return Boolean(document.querySelector('#pgBasicPlayer .btnStop'));
  },
  toggle: function () {
    document.querySelector('#pgBasicPlayer .btnPlay button, #pgBasicPlayer .btnStop button').click();
  },
  next: function () {
    document.querySelector('#pgBasicPlayer .btnNext button').click();
  },
  favorite: function (){
    document.querySelector('#pgBasicPlayer .btnLikeTrack[style*="display: inline"] button,' +
                           '#pgBasicPlayer .btnLikeTrackCancel[style*="display: inline"] button').click();
  },
  previous: function () {
    document.querySelector('#pgBasicPlayer .btnPrev button').click();
  },
  pause:function () {
    document.querySelector('#pgBasicPlayer .btnStop button').click();
  },
  trackInfo: function () {
    return {
      image:  document.querySelector('#pgBasicPlayer .thumbnail img').src,
      artist: document.querySelector('#pgBasicPlayer .trackInfo .artist *[title]').getAttribute('title'),
      album:  document.querySelector('#pgBasicPlayer .trackInfo .albumtitle').getAttribute('title'),
      track:  document.querySelector('#pgBasicPlayer .trackInfo .tracktitle').getAttribute('title'),
      favorited: Boolean(document.querySelector('#pgBasicPlayer .btnLikeTrackCancel[style*="display: inline"] button'))
    };
  }
};
