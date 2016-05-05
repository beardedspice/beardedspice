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
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*music.bugs.co.kr/newPlayer*'",
    args: "url"
  },
  isPlaying: function isPlaying () { return bugs.player.isPlayingTrack; },
  toggle: function toggle () { bugs.player.playButtonHandler().call(); },
  next: function next () { bugs.player.nextButtonHandler().call(); },
  favorite: function favorite (){
    if (document.querySelector('.btnLikeTrackCancel').style.display == "none") {
      bugs.player.likeButtonHandler().call();
    }
    bugs.player.likeCancelButtonHandler().call();
  },
  previous: function previous () { bugs.player.prevButtonHandler().call(); },
  pause:function pause () {
    if (bugs.player.isPlayingTrack) {
      bugs.player.playButtonHandler().call();
    }
  },
  trackInfo: function trackInfo () {
    return {
      image:  document.querySelector('.thumbnail > img').getAttribute('src'),
      track:  bugs.player.getCurrentTrackInfo().track_title,
      artist: bugs.player.getCurrentTrackInfo().artist_nm,
    }
  }
}
