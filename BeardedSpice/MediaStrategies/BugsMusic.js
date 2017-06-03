//
//  BugsMusicStrategy.m
//  BeardedSpice
//
//  Created by Jinseop Kim on 01/03/16.
//  Copyright © 2016 BeardedSpice. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"Bugs Music",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.bugs.co.kr/newPlayer*'",
    args: ["URL"]
  },
  isPlaying: function () { return bugs.player.isPlayingTrack; },
  toggle: function () { bugs.player.playButtonHandler(); },
  next: function () { bugs.player.nextButtonHandler(); },
  favorite: function (){
    if (document.querySelector('.btnLikeTrackCancel').style.display == "none") {
      try {
        bugs.player.likeButtonHandler();
      } catch (err) {}
    } else {
      bugs.player.likeCancelButtonHandler();
    }
  },
  previous: function () { bugs.player.prevButtonHandler(); },
  pause:function () {
    if (bugs.player.isPlayingTrack) {
      bugs.player.playButtonHandler();
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
