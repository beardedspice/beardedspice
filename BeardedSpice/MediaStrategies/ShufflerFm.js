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
  isPlaying: function () {},
  toggle: function () {
    var ap=window.SHUFFLER.audioPlayer;
    if(ap.playing()) {
      ap.pause();
    } else {
      ap.play();
    }
  },
  next: function () {window.SHUFFLER.playerController.onAudioPlayerPlaybackEndHandler();},
  favorite: function () {},
  previous: function () {SHUFFLER.playerController.onPlayerUiButtonPrevHandler();},
  pause: function () {window.SHUFFLER.audioPlayer.pause();},
  trackInfo: function () {}
}
