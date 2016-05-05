//
//  ShufflerFm.plist
//  BeardedSpice
//
//  Created by Breyten Ernsting on 1/16/14.
//  Copyright (c) 2013 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:1,
  displayName:"Shuffler.fm",
  acceptMethod: "predicateOnTab",
  acceptParams: {
    format:"SELF LIKE[c] '*shuffler.fm/tracks*'",
    args:"url"
  },
  isPlaying: function isPlaying () {},
  toggle: function toggle () {
    var ap=window.SHUFFLER.audioPlayer;
    if(ap.playing()) {
      ap.pause();
    } else {
      ap.play();
    }
  },
  next: function next () {window.SHUFFLER.playerController.onAudioPlayerPlaybackEndHandler();},
  favorite: function favorite () {},
  previous: function previous () {SHUFFLER.playerController.onPlayerUiButtonPrevHandler();},
  pause: function pause () {window.SHUFFLER.audioPlayer.pause();},
  trackInfo: function trackInfo () {}
}
