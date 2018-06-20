//
//  AmazonMusic.plist
//  BeardedSpice
//
//  Created by Brandon P Smith on 7/23/14.
//  Edited by Matteo Gaggiano on 6/20/2018.
//  Copyright (c) 2014 Tyler Rhodes / Jose Falcon. All rights reserved.
//
BSStrategy = {
  version:2,
  displayName:"Amazon Music",
  accepts: {
    method: "predicateOnTab",
    format:"%K LIKE[c] '*music.amazon.*'",
    args: ["URL"]
  },
  isPlaying: function () {
    if (window.amznMusic)
      return window.amznMusic.widgets.player.isPlaying();
    return window.document.querySelector('.playbackActive .playbackControls .button.playerIcon.playButton.playerIconPause') !== null;
  },
  toggle: function () {
    if (window.amznMusic)
      return window.amznMusic.widgets.player.playHash('togglePlay');
    return window.document.querySelector('.playbackActive .playbackControls .button.playerIcon.playButton').click();
  },
  next: function () {
    if (window.amznMusic)
      return window.amznMusic.widgets.player.playHash('next');
    return window.document.querySelector('.playbackActive .playbackControls .button.nextButton').click();
  },
  previous: function () {
    if (window.amznMusic)
      return window.amznMusic.widgets.player.playHash('previous');
    return window.document.querySelector('.playbackActive .playbackControls .button.previousButton').click();
  },
  pause: function () {
    if (window.amznMusic)
      window.amznMusic.widgets.player.pause();
    else
      window.document.querySelector('.playbackActive .playbackControls .button.playerIcon.playButton.playerIconPause').click();
  },
  trackInfo: function () {
    var data = {};
    if (window.amznMusic) {
      data = window.amznMusic.widgets.player.getCurrent()['metadata'];
    } else {
      data['title'] = window.document.querySelector('.trackTitle a').getAttribute('title');
      data['albumName'] = window.document.querySelector('.trackArtist a').getAttribute('title');
      data['artistName'] = window.document.querySelector('.trackSourceLink a').innerText;
      data['albumCoverImageSmall'] = window.document.querySelector('.renderImage').getAttribute('src');
    }
    return {
        'track': data['title'],
        'artist': data['albumName'],
        'album': data['artistName'],
        'image': data['albumCoverImageSmall']
    }
  }
}
