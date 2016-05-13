//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by Jinseop Kim on 01/03/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Bugs Music",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.bugs.co.kr/newPlayer*'",
    args: ["URL"]
  },
  isPlaying: function () { return bugs.player.isPlayingTrack; },
  toggle: function () { bugs.player.playButtonHandler().call(); },
  next: function () { bugs.player.nextButtonHandler().call(); },
  favorite: function (){
    if (document.querySelector('.btnLikeTrackCancel').style.display == "none") {
      bugs.player.likeButtonHandler().call();
    }
    bugs.player.likeCancelButtonHandler().call();
  },
  previous: function () { bugs.player.prevButtonHandler().call(); },
  pause:function () {
    if (bugs.player.isPlayingTrack) {
      bugs.player.playButtonHandler().call();
    }
  },
  trackInfo: function () {
    return {
      image:  document.querySelector('.thumbnail > img').getAttribute('src'),
      track:  bugs.player.getCurrentTrackInfo().track_title,
      artist: bugs.player.getCurrentTrackInfo().artist_nm,
    }
  }
}
